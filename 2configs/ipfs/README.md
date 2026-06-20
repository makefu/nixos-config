# omo-container.nix — operator guide

Declarative kubo (go-ipfs) running on `omo` inside a `systemd-nspawn`
container that shares a dedicated network namespace with a WireGuard
tunnel to `gum`. The container has no host networking and no published
ports — every byte in or out either rides the wg tunnel or comes in
through the host control plane described below.

For the design rationale (leak model, netns layout, routing) read the
header comment in `omo-container.nix` itself.

## Control surfaces

There are no remote APIs. The kubo HTTP API (`:5001`) and gateway
(`:8080`) are not bound on the host and are unreachable from omo's main
netns. All operator access goes through the host:

| from              | how                                         |
| ----------------- | ------------------------------------------- |
| LAN / remote      | `ssh root@omo.lan`                          |
| omo host shell    | `ipfs <args>` wrapper (root only)           |
| omo host shell    | `nixos-container run kubo -- ipfs <args>`   |
| omo host shell    | `machinectl shell kubo` for an interactive root shell inside the container |
| omo host shell    | `journalctl -u container@kubo -f` for container-level logs |
| omo host shell    | `nixos-container run kubo -- journalctl -u ipfs -f` for daemon logs |

The wrapper is a `pkgs.writeShellScriptBin "ipfs"` declared in
`omo-container.nix` and attached to `users.users.root.packages`, so it
is on root's PATH after the next `nixos-rebuild switch`. It forwards
argv, stdin, stdout and exit code to `nixos-container run kubo -- ipfs`.

## Pinning files from the host

The container's `/var/lib/ipfs` is the host's `/media/cryptX/ipfs`
bind-mount, but the container has no view of arbitrary host paths.
Push file contents through stdin instead.

### One-off file

```sh
ssh root@omo.lan
ipfs add -Q < /path/on/omo/file.bin
# prints the root CID; pin is implicit (`ipfs add` pins by default)
```

`-Q` keeps only the final CID on stdout so it composes with shell.

### Stream from your laptop without staging on omo

```sh
# adds + pins, never touches omo's disk outside the kubo datastore
cat ./local-file | ssh root@omo.lan ipfs add -Q
```

### Pin an already-known CID (fetch + retain)

```sh
ssh root@omo.lan ipfs pin add <cid>
# blocks until the DAG is fully fetched through the wg tunnel
ssh root@omo.lan ipfs pin add --progress <cid>   # with progress meter
```

### Directory trees

`ipfs add` cannot read a host directory through stdin. Two options:

1. Tar-stream it in, unpack inside the container:

   ```sh
   tar -C /srcdir -cf - . \
     | ssh root@omo.lan 'nixos-container run kubo -- sh -c \
         "mkdir -p /var/lib/ipfs/staging/$$ \
          && tar -C /var/lib/ipfs/staging/$$ -xf - \
          && ipfs add -Qr /var/lib/ipfs/staging/$$ \
          && rm -rf /var/lib/ipfs/staging/$$"'
   ```

2. Or stage on the host bind-mount and add by path. The host path
   `/media/cryptX/ipfs/<x>` appears inside the container as
   `/var/lib/ipfs/<x>`:

   ```sh
   ssh root@omo.lan 'cp -r /some/host/dir /media/cryptX/ipfs/staging \
     && chown -R ipfs:ipfs /media/cryptX/ipfs/staging \
     && ipfs add -Qr /var/lib/ipfs/staging \
     && rm -rf /media/cryptX/ipfs/staging'
   ```

   Note: kubo has `Experimental.FilestoreEnabled = true`, so
   `ipfs add --nocopy -r /var/lib/ipfs/staging` would keep the original
   files in place and only store references — useful for large blobs you
   want to keep on the FS as-is. The files must then stay where they
   are or pins will dangle.

## Inspecting and maintenance

```sh
ssh root@omo.lan ipfs id                           # peer id + addrs
ssh root@omo.lan ipfs swarm peers | wc -l          # connected peers
ssh root@omo.lan ipfs repo stat                    # datastore size
ssh root@omo.lan ipfs pin ls --type=recursive      # all explicit pins
ssh root@omo.lan ipfs pin rm <cid>                 # unpin (does not delete blocks)
ssh root@omo.lan ipfs repo gc                      # collect unpinned blocks
ssh root@omo.lan ipfs bitswap stat                 # tunnel throughput sanity
```

Datastore cap is `Datastore.StorageMax = "100GB"` in `omo-container.nix`.
GC runs only on demand — schedule it manually after large unpins.

## Restarting / redeploying

The container is brought up by `container@kubo.service` and depends on
`media-cryptX.mount`, `netns-ipfs.service` and `wireguard-ipfs-wg.service`.

```sh
ssh root@omo.lan systemctl restart container@kubo            # daemon-only bounce
ssh root@omo.lan systemctl restart wireguard-ipfs-wg         # rebuild tunnel; container keeps running
ssh root@omo.lan systemctl restart netns-ipfs                # nuclear: tears down netns, wg and container
```

After editing `omo-container.nix`, deploy from this repo with the
project's normal rebuild flow (e.g. `nixos-rebuild switch --flake
.#omo --target-host root@omo.lan`). The wrapper script is rebuilt as
part of the activation and immediately visible to a fresh root shell.

## Things that intentionally do NOT work

- No `curl http://omo.lan:5001/api/v0/...` — the API is bound only on
  the container's loopback, which lives inside the `ipfs` netns.
- No `ipfs add /etc/anything` from the host — the container cannot see
  host paths outside the `/var/lib/ipfs` bind-mount.
- No IPv4/IPv6 to kubo from outside the wg tunnel. If you need a public
  gateway, run one on `gum` and have it talk to kubo over the tunnel.
