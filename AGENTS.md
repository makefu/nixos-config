# Agent notes for this repo

NixOS flake managed via [clan-cli](https://docs.clan.lol). Hosts +
shared snippets + custom modules + custom packages, plus a tinc mesh
and several wireguard overlays.

## Directory layout

```
flake.nix              flake inputs + clan() invocation (lists hosts)
inventory.json         clan inventory (mostly unused — hosts live in flake.nix)
machines/<host>/       per-host top-level config
  config.nix           entry point: imports + machine-wide overrides
  hw/                  hardware bits (network ifname, disk, gpu, …)
2configs/              shared, opt-in NixOS snippets (the "config library")
3modules/              custom option-providing NixOS modules (auto-loaded)
4lib/                  helper functions
5pkgs/                 custom packages + overlays (5pkgs/default.nix is the overlay)
sops/secrets/<name>/   clan-managed sops-encrypted secrets
0tests/                experimental / scratch
secrets/<host>/        per-host plaintext state checked in (e.g. ssh hostkeys)
                       NEVER put private keys here — use sops.
```

## Host management

### Adding a host

1. Add the host name to the `lib.genAttrs` list in
   `flake.nix:154` (`machines = lib.genAttrs [ ... ]`).
2. Create `machines/<host>/config.nix` and `machines/<host>/hw/…`.
3. The `nixosConfigurations.<host>` then exists; build via
   `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`.
4. Wire host into the krebs hostmap (`krebs.build.host =
   config.krebs.hosts.<host>;` at the bottom of `config.nix`) — this
   plumbs the host's tinc/retiolum/wiregrill/internet addresses
   coming from `stockholm.nixosModules.hosts`.
5. For non-`x86_64-linux` hosts, set the platform in the genAttrs
   block (see `cake` → `aarch64-linux`).

### Per-host conventions

```nix
# machines/<host>/config.nix
{ config, pkgs, lib, ... }: {
  imports = [
    ./hw/<host>                          # hardware
    ../../2configs/default.nix           # baseline (vim, ssh, krebs, …)
    ../../2configs/tinc/retiolum.nix     # tinc mesh
    ../../2configs/wireguard/euer/client.nix   # or server.nix on gum
    # ... pick service snippets from 2configs/ here
  ];
  krebs.build.host = config.krebs.hosts.<host>;
  # clan deploy target (ssh user@host used by `clan machines update`)
  clan.core.networking.targetHost = "root@<host>.i";
}
```

`<host>.i` resolves through the retiolum/tinc DNS.

### Deployment

Inside the dev shell (`nix develop` from repo root, ships clan-cli +
nixos-rebuild-ng + age + euer-add-device):

```sh
clan machines update <host>             # build remotely on host & switch
clan machines update <host> --target-host root@<other-ip>   # one-off target override
nixos-rebuild switch --flake .#<host> --target-host root@<host>   # alt
```

`clan.core.networking.targetHost` per machine sets the default ssh
target; override with `--target-host` when reachability changes.

## Service / config snippet pattern (`2configs/`)

Every `.nix` under `2configs/` is a self-contained NixOS module that
can be `imports = [ … ]`-ed from any machine. Conventions:

- One concern per file (`2configs/ipfs/serve.nix`,
  `2configs/home/jellyfin.nix`).
- Subdirs group related snippets (`2configs/ipfs/`,
  `2configs/wireguard/euer/`, `2configs/home/`).
- A snippet referencing host-specific data (`omo`, `gum`) usually has
  the host name in its path (`2configs/ipfs/omo-container.nix`,
  `2configs/share/omo.nix`, `2configs/home/zigbee/omo.nix`).
- Shared building blocks that take arguments are written as functions
  in their own file and imported via `(import ./foo.nix { … })`
  (`2configs/wireguard/euer/container-netns.nix`). Wrap with a fixed
  wrapper file (`omo-ipfs-netns.nix`) when the same instantiation
  needs to be imported from multiple consumers — NixOS dedupes module
  imports by file path, so the netns/wg services get declared once.

### Imports in `machines/<host>/config.nix`

Just append the snippet path to the `imports` list. Pulling a service
out is the inverse — comment / delete the line. Service snippets
should never assume they are imported by every host; gate
host-specific behavior with `lib.mkIf` on `krebs.build.host.name`
when needed.

### `2configs/default.nix`

Baseline pulled in by most hosts: user passwords, vim, ssh hostkeys,
binary cache, krebs core, `system.stateVersion`. Newly created
machines should import this unless there's a strong reason not to
(see `machines/liveiso/` for a counter-example).

## Custom NixOS modules (`3modules/`)

Every `.nix` (except those starting with `.`) under `3modules/` is
auto-imported into every host via `self.nixosModules.default` (built
in `flake.nix:206`). These provide options under `makefu.*`:

```
makefu.server.primary-itf       # required by VPN snippets, set in machines/<host>/hw/
makefu.full-populate            # full clone of nixpkgs on rebuild
makefu.euer-wg.{peers,client,server,...}   # internal wireguard overlay
…
```

To add a new option-providing module: drop the file into `3modules/`
and add it to the `imports` list in `3modules/default.nix` (no
auto-imports under sub-attrs — `default.nix` is the registry).

## Custom packages / overlays (`5pkgs/`)

`5pkgs/default.nix` is exposed as `self.overlays.default` and applied
via the per-host `nixpkgs.config`. New packages: drop a subdir under
`5pkgs/<name>/` with a `default.nix` and add it to the overlay.
Refer to existing entries (`5pkgs/bambu-studio`, `5pkgs/awesomecfg`)
for shape.

## Secrets — clan + sops

See full reference below. TL;DR:

```sh
echo -n "<value>" | clan secrets set --machine <host> --user <user> <name>
# consume in NixOS:
sops.secrets."<name>" = {};
config.sops.secrets."<name>".path   # → /run/secrets/<name>
```

`clan secrets set` auto-commits the `sops/secrets/<name>/` directory.
Recipients are listed in `.sops.yaml` (host age keys + user PGP key);
keep in sync when adding a new host or user.

## VPN overlays

This repo runs several overlapping networks. Choose by intent:

| Network        | Tech                | Purpose                                                                                          | Snippets to import                                                |
|----------------|---------------------|--------------------------------------------------------------------------------------------------|-------------------------------------------------------------------|
| **retiolum**   | tinc                | Krebs mesh: 10.243.0.0/16 + `42::/16` IPv6 ULA, `<host>.r` / `<host>.i` DNS, peer-to-peer.       | `2configs/tinc/retiolum.nix` (client + server are the same)       |
| **wiregrill**  | wireguard           | Krebs hub-and-spoke wg overlay, also routes DNS via dnsmasq on the server (gum).                | `2configs/wireguard/wiregrill-client.nix`, `…/wiregrill-server.nix` |
| **euer**       | wireguard           | Hetzner-anchored hub (gum) that gives clients an IPv4-NATed + publicly-routed IPv6 (via NDP proxy). Carries the omo "container netns" traffic. | `2configs/wireguard/euer/{client,server,common}.nix`             |
| **(legacy)**   | wireguard           | Old `wg0` peer list (smartphones, x-test). Pre-dates the euer network — do not extend.            | `2configs/wireguard/server.nix`, `…/thierry.nix`                  |
| tailscale / netbird / zerotier | upstream services | Optional, not deployed by default.                                                              | `2configs/networking/{tailscale,netbird,zerotier}.nix`            |

### retiolum (tinc)

Provided by `stockholm.nixosModules.tinc`. The repo wraps it in
`2configs/tinc/retiolum.nix`:

- enables `krebs.tinc.retiolum`
- packages `inputs.tincr.packages.<system>.tincd` (Rust tincd)
- pulls the RSA + ed25519 private keys from sops secrets
  `<host>-retiolum.rsa_key.priv` / `<host>-retiolum.ed25519_key.priv`
- opens the tinc port from `config.krebs.build.host.nets.retiolum.tinc.port`

Hosts in the mesh are defined in `stockholm` (`krebs.hosts.<name>`).
`<host>.r` (IPv4) and `<host>.i` (mixed v4/v6) names work everywhere
in the mesh.

### wiregrill

Internal wireguard overlay with one server (gum) and many clients.
Server file also runs `dnsmasq` bound to the tunnel interface and
forwards `1.1.1.1`.

Add a new client: import `wiregrill-client.nix`, ensure the host has
a `wiregrill` net entry in stockholm's `krebs.hosts`, and store the
private key as clan secret `<host>-wiregrill.key`.

### euer (wireguard hub at gum)

Custom module: `3modules/euer-wg.nix`. Peer registry +
shared/server/client config lives in
`2configs/wireguard/euer/common.nix` (imported by both
`client.nix` and `server.nix`). The server (gum) maintains an NDP
proxy entry per peer that has a `publicV6`, so peers transparently
expose a public IPv6 even though they sit behind NAT.

- ULA: `fd42:e1e0::/64`
- IPv4 (NATed by gum): `172.27.70.0/24`
- Public IPv6: gum's `2a01:4f8:1c17:5cdf::/64` subnet, one address per peer

Add a peer (NixOS host):

1. Append to the `peers` attrset in `common.nix` with allocated
   `ula` / `ipv4` / `publicV6` and the wg `publicKey`.
2. Store the matching private key as clan secret
   `<host>-euer-wg.key`.
3. Add per-peer `openTCPPorts = [ … ];` if you want gum's NDP-proxy
   firewall to forward TCP to the peer's `publicV6`.
4. Rebuild gum (loads peer + NDP proxy + firewall) and the peer host.

Add a peer (external device, smartphone, …):

```sh
nix run .#euer-add-device -- new <device>
nix run .#euer-add-device -- qr  <device>      # show as QR
nix run .#euer-add-device -- get <device>      # print wg config
```

Script allocates next free addresses, generates a keypair, edits
`common.nix`, stores three clan secrets
(`<device>-euer-wg.key` / `.pub` / `-euer-wireguard-config`). Then
rebuild gum.

### Container in its own euer netns (omo pattern)

`2configs/wireguard/euer/container-netns.nix` is a function module
that creates a network namespace whose only interface is a dedicated
wireguard tunnel to gum, with no veth back to the host. Used by
both kubo and radicle on omo (they share `netns=ipfs`,
`peer=omo-ipfs`). See `2configs/ipfs/omo-container.nix` /
`2configs/radicle/omo-container.nix` for the consumer-side wiring.
The wrapper file `omo-ipfs-netns.nix` exists so multiple consumers
can import the same instantiation; NixOS module dedup ensures the
netns + wg services are declared only once.

## Clan secrets reference

Secrets live under `sops/secrets/<name>/`. Each secret is a
directory, not a file:

```
sops/secrets/<name>/
  secret              # sops-encrypted ciphertext
  machines/<host>     # marker: this host's age key can decrypt
  users/<user>        # marker: this user's age/pgp key can decrypt
```

Recipients are listed in `.sops.yaml` (host age keys + user PGP key).

### Commands

```sh
# create / overwrite a secret (reads value from stdin)
echo -n "<value>" | clan secrets set --machine <host> --user <user> <name>

# read a file as the secret
cat /path/to/key | clan secrets set --machine <host> --user <user> <name>

# edit in $EDITOR instead of pasting
clan secrets set --machine <host> --user <user> -e <name>

# read a secret back
clan secrets get <name>

# list (optional regex)
clan secrets list [regex]

# rename / remove
clan secrets rename <old> <new>
clan secrets remove <name>

# rotate recipients without changing the value
clan secrets users    add-secret <user> <name>
clan secrets machines add-secret <host> <name>
```

`clan secrets set` auto-commits the resulting `sops/secrets/<name>/`
tree. Do not commit those files by hand.

### Consuming in NixOS

```nix
sops.secrets."<name>" = {};                  # default: root:root 0400 at /run/secrets/<name>
sops.secrets."<name>" = { owner = "foo"; mode = "0440"; };
# path:
config.sops.secrets."<name>".path            # → /run/secrets/<name>
```

Inside a `containers.<x>` block, bind-mount the host secret in:

```nix
containers.<x>.bindMounts."/run/<name>" = {
  hostPath = config.sops.secrets."<name>".path;
  isReadOnly = true;
};
```

The container's NixOS does not have sops-nix — always go through a
host bind-mount.

### Naming convention

`<host>-<purpose>[.<ext>]`, e.g.
`omo-ipfs-euer-wg.key`, `omo-radicle.key`, `omo-syncthing.cert`.
External (non-NixOS) wg peers also get
`<device>-euer-wireguard-config` (full client config string).

## Build / eval recipes

```sh
# validate the whole host evaluates
nix eval .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath

# build a leaf derivation to validate it (e.g. radicle config validator)
nix build .#nixosConfigurations.<host>.config.containers.<x>.config.services.<svc>.<attr>

# look up any attribute under the host config
nix eval --json .#nixosConfigurations.<host>.config.<dotted.path>

# inspect a failed build
nix log /nix/store/<…>.drv | grep -i error

# checks (all hosts toplevel build)
nix flake check
```

## Conventions for editing this repo

- Track newly created `.nix` files before evaluating: `git add -AN
  <file>`. Untracked files are invisible to flakes.
- Use `pueue` for any rebuild or deploy that may exceed 10s (the
  global agent instructions require this).
- When adding new options under `makefu.*`, declare them in
  `3modules/` and register the file in `3modules/default.nix`.
- Comment the **why** (incidents, constraints, non-obvious
  invariants), not the **what** (variable names should be enough).
