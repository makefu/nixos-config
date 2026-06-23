{ config, pkgs, lib, ... }:

# Declarative Radicle seed node on omo, running inside a NixOS systemd-nspawn
# container that joins the same wireguard-isolated `ipfs` netns used by the
# kubo container (see 2configs/ipfs/omo-container.nix). Sharing the netns
# means we re-use the `omo-ipfs` wireguard peer — radicle-node listens on
# the same publicV6, just on a different TCP port (8776).
#
# Identity
# --------
# Public key is committed below; matching private key is stored as the
# clan-managed sops secret `omo-radicle.key` (unencrypted OpenSSH ed25519,
# `cipher=none`, generated via `rad auth --alias omo` with an empty
# RAD_PASSPHRASE). Regenerating the keypair means re-running `rad auth`,
# replacing `publicKeyLiteral` here and `clan secrets set omo-radicle.key`.

let
  # Same netns + wg interface as ipfs — radicle re-uses the omo-ipfs peer.
  netns = "ipfs";
  ifname = "ipfs-wg";
  dataDir = "/media/silent/db/radicle";

  # Pinned seed repositories. Add more RIDs as needed.
  pinnedRepos = [
    "rad:zaCSBVa8UbKNEWBcmRTW1m9fZXhu"
  ];

  # Public ed25519 from `rad auth`. The nixpkgs radicle module rejects keys
  # with a trailing comment, so keep the line as just `ssh-ed25519 <b64>`.
  publicKeyLiteral = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF39eDCYctHnyEbNexSGCSCb27+tK8ZvhCKrMN0zRTu5";

  # Reachable address announced to peers. Matches omo-ipfs.publicV6.
  externalV6 = config.makefu.euer-wg.peers."omo-ipfs".publicV6;

  # Stable uid/gid so the bind-mounted dataDir is owned by the same id
  # on host and inside the container. radicle has no nixpkgs-reserved id;
  # 391 is unused on omo.
  radicleUid = 391;
  radicleGid = 391;

  # Host-side wrapper: `rad` on the host shells into the container's
  # rad-system (which enters radicle-node's mount/user namespace).
  radHost = pkgs.writeShellScriptBin "rad" ''
    exec ${pkgs.nixos-container}/bin/nixos-container run radicle -- rad-system "$@"
  '';
in {
  imports = [
    ../wireguard/euer/omo-ipfs-netns.nix
  ];

  sops.secrets."omo-radicle.key" = {};

  users.users.root.packages = [ radHost ];

  users.users.radicle = {
    isSystemUser = true;
    group = "radicle";
    uid = radicleUid;
    description = "radicle seed-node data owner (host side)";
  };
  users.groups.radicle.gid = radicleGid;

  systemd.tmpfiles.settings."10-radicle-data" = {
    "${dataDir}".d = {
      user = "radicle";
      group = "radicle";
      mode = "0750";
    };
  };

  containers.radicle = {
    autoStart = true;
    privateNetwork = false;
    extraFlags = [
      "--network-namespace-path=/run/netns/${netns}"
      "--resolv-conf=off"
    ];
    bindMounts = {
      "/var/lib/radicle" = {
        hostPath = dataDir;
        isReadOnly = false;
      };
      "/etc/resolv.conf" = {
        hostPath = "/etc/netns/${netns}/resolv.conf";
        isReadOnly = true;
      };
      "/run/radicle.key" = {
        hostPath = config.sops.secrets."omo-radicle.key".path;
        isReadOnly = true;
      };
    };
    config = { config, pkgs, lib, ... }: {
      system.stateVersion = "26.05";

      networking.useDHCP = false;
      networking.useHostResolvConf = false;
      networking.firewall.enable = false;
      systemd.network.enable = false;

      # Pin uid/gid to match the host bind-mount owner.
      users.users.radicle.uid = lib.mkForce radicleUid;
      users.groups.radicle.gid = lib.mkForce radicleGid;

      services.radicle = {
        enable = true;
        privateKey = "/run/radicle.key";
        publicKey = publicKeyLiteral;
        node = {
          listenAddress = "[::]";
          listenPort = 8776;
        };
        settings = {
          node.alias = "omo";
          node.externalAddresses = [
            "[${externalV6}]:8776"
          ];
          web.pinned.repositories = pinnedRepos;
        };
      };
    };
  };

  # Wait for /media/silent (xfs on nvme, no mergerfs) + netns + wg.
  systemd.services."container@radicle" = {
    after = [
      "media-silent.mount"
      "netns-${netns}.service"
      "wireguard-${ifname}.service"
    ];
    requires = [
      "media-silent.mount"
      "netns-${netns}.service"
      "wireguard-${ifname}.service"
    ];
    unitConfig.RequiresMountsFor = [ dataDir ];
  };
}
