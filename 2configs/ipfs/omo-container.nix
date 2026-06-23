{ config, pkgs, lib, ... }:

# Declarative IPFS (kubo) on omo, running inside a NixOS systemd-nspawn
# container that joins a pre-existing network namespace whose only
# interface is a dedicated wireguard tunnel to the euer server (gum).
#
# Design / leak model
# -------------------
#   * The container has no host network access of any kind: no veth, no
#     bridge, no published port. systemd-nspawn is told via
#     `--network-namespace-path=/run/netns/ipfs` to share the netns we
#     create ourselves. Inside that netns there is exactly one non-loopback
#     interface — the `ipfs-wg` wireguard tunnel.
#   * IPv4 reaches the internet via gum's masquerade. IPv6 is routed
#     end-to-end: the container's publicV6 is announced by gum via NDP
#     proxy on its external interface.
#   * The ONLY traffic from the container that ever leaves the wg tunnel is
#     the *encrypted* UDP between the wg interface and gum's IPv4 endpoint
#     (142.132.189.140:51826). That socket lives in the host's main netns,
#     not in the ipfs netns, and is unreachable from inside the container.
#     Pinning the endpoint to IPv4 also keeps the encrypted side off omo's
#     main `euer` interface (which has ipv6DefaultRoute=true) and avoids a
#     wg-over-wg loop.
#   * Data lives at /media/cryptX/ipfs (decrypted at boot). The container
#     only starts once that mount is up.
#
# Why a NixOS container and not the official ipfs/kubo image
# ----------------------------------------------------------
# `services.kubo` from nixpkgs gives us a fully declarative repo config,
# integrates with systemd journaling, and uses the kubo binary from the
# pinned nixpkgs revision rather than whatever upstream Docker Hub tag
# happens to point at today.

let
  netns = "ipfs";
  ifname = "ipfs-wg";
  dataDir = "/media/cryptX/ipfs";

  # Host-side wrapper: proxies any `ipfs ...` invocation into the kubo
  # container. stdin/stdout/exit code pass through, so the usual recipes
  # (`ipfs add -Q < /path/to/file`, `ipfs pin add <cid>`, `ipfs cat <cid>`)
  # work unchanged. See ./README.md for the full operator playbook.
  ipfsHost = pkgs.writeShellScriptBin "ipfs" ''
    exec ${pkgs.nixos-container}/bin/nixos-container run kubo -- ipfs "$@"
  '';

  # uid 261 is the NixOS-reserved id for the ipfs user
  # (lib/nixos/misc/ids.nix). With systemd-nspawn and no user-namespace
  # remapping, the in-container ipfs uid maps 1:1 to the host so the
  # bind-mounted dataDir is owned by the same uid on both sides.
  ipfsUid = config.ids.uids.ipfs;
  ipfsGid = config.ids.gids.ipfs;

  selfPeer = config.makefu.euer-wg.peers."omo-ipfs";
  serverPeer = config.makefu.euer-wg.peers.gum;
  # match 2configs/wireguard/euer/client.nix for omo
  serverEndpoint = "142.132.189.140";
  port = config.makefu.euer-wg.port;

  keyPath = config.sops.secrets."omo-ipfs-euer-wg.key".path;
in {

  sops.secrets."omo-ipfs-euer-wg.key" = {};

  # `ipfs` on PATH for root: thin wrapper into the kubo container so
  # operating the daemon does not require remembering the
  # `nixos-container run kubo -- ipfs ...` prefix.
  users.users.root.packages = [ ipfsHost ];

  # Host-side `ipfs` user/group: only purpose is to give the bind-mounted
  # data directory a stable owner that matches the in-container ipfs user.
  users.users.ipfs = {
    isSystemUser = true;
    group = "ipfs";
    uid = ipfsUid;
    description = "ipfs/kubo data owner (host side)";
  };
  users.groups.ipfs.gid = ipfsGid;

  systemd.tmpfiles.settings."10-ipfs-data" = {
    "${dataDir}".d = {
      user = "ipfs";
      group = "ipfs";
      mode = "0750";
    };
  };

  # 1) network namespace ------------------------------------------------------
  systemd.services."netns-${netns}" = {
    description = "Network namespace ${netns} (kubo)";
    wantedBy = [ "multi-user.target" ];
    before = [
      "wireguard-${ifname}.service"
      "container@kubo.service"
    ];
    path = with pkgs; [ iproute2 gnugrep ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "netns-${netns}-up" ''
        set -eu
        if ! ip netns list | grep -qx '${netns}'; then
          ip netns add '${netns}'
        fi
        ip -n '${netns}' link set lo up
      '';
      ExecStop = "${pkgs.iproute2}/bin/ip netns del '${netns}'";
    };
  };

  # systemd-nspawn does NOT bind /etc/netns/<ns>/resolv.conf into the
  # container the way `ip netns exec` does, so we additionally bind-mount
  # this same file at /etc/resolv.conf via `containers.kubo.bindMounts`.
  environment.etc."netns/${netns}/resolv.conf".text = ''
    nameserver 1.1.1.1
    nameserver 9.9.9.9
  '';

  # 2) wireguard tunnel inside the netns -------------------------------------
  # Custom service rather than networking.wireguard.interfaces — that module
  # is networkd-backed on omo and networkd does not support
  # interfaceNamespace. Hand-rolling lets us keep everything else untouched.
  systemd.services."wireguard-${ifname}" = {
    description = "WireGuard tunnel ${ifname} (lives in ${netns} netns)";
    wantedBy = [ "multi-user.target" ];
    after = [
      "netns-${netns}.service"
      "network-pre.target"
      "sops-install-secrets.service"
    ];
    requires = [ "netns-${netns}.service" ];
    partOf = [ "netns-${netns}.service" ];
    before = [ "container@kubo.service" ];

    path = with pkgs; [ iproute2 wireguard-tools ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -eu

      # clean any leftover interface from a previous, half-failed run
      if ip link show '${ifname}' >/dev/null 2>&1; then
        ip link del dev '${ifname}'
      fi
      if ip -n '${netns}' link show '${ifname}' >/dev/null 2>&1; then
        ip -n '${netns}' link del dev '${ifname}'
      fi

      # Create the wg device in the host namespace so the encrypted UDP
      # socket lives there (and follows omo's normal default route to
      # gum's IPv4 endpoint), then hand the plaintext side off into the
      # netns. Pinning the endpoint to IPv4 is what guarantees the
      # encrypted side does not loop back through omo's main `euer`
      # tunnel (which has ipv6DefaultRoute=true).
      ip link add dev '${ifname}' type wireguard
      wg set '${ifname}' \
        private-key '${keyPath}' \
        peer '${serverPeer.publicKey}' \
          endpoint '${serverEndpoint}:${toString port}' \
          persistent-keepalive 25 \
          allowed-ips '172.27.70.0/24,0.0.0.0/0,fd42:e1e0::/64,${selfPeer.publicV6}/128,::/0'
      ip link set dev '${ifname}' netns '${netns}'

      ip -n '${netns}' addr add '${selfPeer.ipv4}/24'      dev '${ifname}'
      ip -n '${netns}' addr add '${selfPeer.ula}/64'       dev '${ifname}'
      ip -n '${netns}' addr add '${selfPeer.publicV6}/128' dev '${ifname}'
      ip -n '${netns}' link set dev '${ifname}' up

      # IPv4: default route through the tunnel (NATed by gum).
      ip -n '${netns}' route add 172.27.70.0/24 dev '${ifname}' 2>/dev/null || echo "route to 172.27.70.0 already exists"
      ip -n '${netns}' route add default        dev '${ifname}'
      # IPv6: default route through the tunnel. gum has us in its NDP
      # proxy list for ${selfPeer.publicV6}, so packets back to us are
      # delivered. There is no other v6 route in this netns, so any v6
      # destination is forced through wg.
      ip -n '${netns}' -6 route add fd42:e1e0::/64 dev '${ifname}'
      ip -n '${netns}' -6 route add default        dev '${ifname}'
    '';
    preStop = ''
      ${pkgs.iproute2}/bin/ip -n '${netns}' link del dev '${ifname}' || true
    '';
  };

  # 3) NixOS container running services.kubo ---------------------------------
  containers.kubo = {
    autoStart = true;
    # We supply the netns ourselves; tell NixOS not to set up its own
    # private network (veth pair, host-side routing, ...) for this
    # container.
    privateNetwork = false;
    extraFlags = [
      "--network-namespace-path=/run/netns/${netns}"
      # do not let nspawn manage /etc/resolv.conf; we bind-mount our own
      "--resolv-conf=off"
    ];
    bindMounts = {
      "/var/lib/ipfs" = {
        hostPath = dataDir;
        isReadOnly = false;
      };
      "/etc/resolv.conf" = {
        hostPath = "/etc/netns/${netns}/resolv.conf";
        isReadOnly = true;
      };
    };
    config = { config, pkgs, lib, ... }: {
      system.stateVersion = "26.05";

      # Tell the container's NixOS not to try to manage networking — the
      # netns is fully set up from the outside and the only interface
      # (ipfs-wg) is already configured.
      networking.useDHCP = false;
      networking.useHostResolvConf = false;
      networking.firewall.enable = false;
      systemd.network.enable = false;

      # mergerfs lazy-enumeration on the host can briefly make the
      # bind-mounted /var/lib/ipfs look empty or partial inside the container.
      # That has bitten us twice:
      #   - kubo's nixpkgs pre-start runs `ipfs init` when `config` is absent,
      #     which would regenerate the peer identity.
      #   - subsequent restarts then trip "missing SHARDING file" and the
      #     default StartLimit (5 in 10s) latches the daemon dead until manual
      #     `systemctl reset-failed ipfs; systemctl restart ipfs`.
      # The host-side ExecStartPre on container@kubo now waits for the repo
      # to be visible, but keep these bumps as belt-and-braces so a transient
      # hiccup retries for minutes instead of seconds.
      systemd.services.ipfs = {
        unitConfig = {
          StartLimitBurst = 30;
          StartLimitIntervalSec = 600;
        };
        serviceConfig.RestartSec = "10s";
      };

      services.kubo = {
        enable = true;
        dataDir = "/var/lib/ipfs";
        settings = {
          Experimental.FilestoreEnabled = true;
          Datastore.StorageMax = "100GB";
          Swarm = {
            ConnMgr = {
              LowWater = 100;
              HighWater = 400;
              GracePeriod = "20s";
            };
            Transports.Network.TCP = true;
            Transports.Network.QUIC = true;
            ResourceMgr.Enabled = true;
            ResourceMgr.MaxMemory = "2GB";
            RelayClient.Enabled = false;
            RelayService.Enabled = false;
          };
          # dhtclient: announces our provider records (so peers can find us
          # by CID) but does not serve DHT routing queries for others.
          Routing.Type = "dhtclient";
        };
      };
    };
  };

  # 4) ordering: wait for storage, netns and wg before the container comes up
  #
  # media-cryptX.mount activates as soon as the mergerfs FUSE process is up
  # — *before* its branches (media-crypt{0..3}.mount) are mounted. On a real
  # boot we have measured >80s between cryptX becoming active and crypt3 (the
  # branch that holds the kubo `config`/`blocks/SHARDING`) finishing fsck and
  # mounting. Just depending on `media-cryptX.mount` therefore lets the
  # container start with an empty bind source, which made kubo's pre-start
  # run a destructive `ipfs init` and then latched the daemon dead via
  # StartLimit on retries. Require every branch explicitly so mergerfs is
  # fully populated before the container starts.
  systemd.services."container@kubo" = {
    after = [
      "media-cryptX.mount"
      "netns-${netns}.service"
      "wireguard-${ifname}.service"
    ];
    requires = [
      "media-cryptX.mount"
      "netns-${netns}.service"
      "wireguard-${ifname}.service"
    ];
    unitConfig.RequiresMountsFor = [
      dataDir
      "/media/crypt0"
      "/media/crypt1"
      "/media/crypt2"
      "/media/crypt3"
    ];
  };
}
