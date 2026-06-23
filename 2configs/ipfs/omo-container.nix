{ config, pkgs, lib, ... }:

# Declarative IPFS (kubo) on omo, running inside a NixOS systemd-nspawn
# container that joins a pre-existing network namespace whose only
# interface is a dedicated wireguard tunnel to the euer server (gum).
#
# The netns + wireguard side is provided by
# 2configs/wireguard/euer/container-netns.nix (shared with radicle). Data
# lives at /media/cryptX/ipfs (decrypted at boot); the container only
# starts once that mount is up.
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
in {
  imports = [
    ../wireguard/euer/omo-ipfs-netns.nix
  ];

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
      imports = [ ./peering.nix ];

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

  # ordering: wait for storage, netns and wg before the container comes up
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
