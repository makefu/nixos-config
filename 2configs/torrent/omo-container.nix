{ config, pkgs, lib, ... }:

# Declarative rtorrent + flood on omo, running inside a NixOS systemd-nspawn
# container that joins the same wireguard-isolated `ipfs` netns used by the
# kubo and radicle containers (see 2configs/{ipfs,radicle}/omo-container.nix).
# Sharing the netns means we re-use the `omo-ipfs` wireguard peer — rtorrent
# announces incoming peer traffic on the peer's routed publicV6, just on a
# different TCP port (51412).
#
# Exposure model
# --------------
# Only the BitTorrent peer port is opened on gum's firewall (added to the
# omo-ipfs peer's openTCPPorts in 2configs/wireguard/euer/common.nix). The
# flood web UI is deliberately NOT exposed externally: it binds the peer's
# ULA (fd42:e1e0::6) inside the netns, which is reachable from every euer
# peer but blocked at gum's firewall for the public internet. omo's host
# nginx fronts it at http://torrent.omo.euer (internal only).

let
  netns = "ipfs";
  ifname = "ipfs-wg";
  dataDir = "/media/cryptX/download/finished";

  peer-port = 51412;
  web-port = 8112;

  # Internal ULA of the shared omo-ipfs peer. flood binds this so the UI is
  # only reachable inside the euer mesh; omo's nginx proxies to it.
  floodHost = config.makefu.euer-wg.peers."omo-ipfs".ula;

  # Run rtorrent/flood as the host's `download` user/group so finished
  # downloads land in the shared media tree with the same ownership as every
  # other download service (see 2configs/share/default.nix). systemd-nspawn
  # maps uids 1:1 here, so the in-container `download` user must reuse the
  # host uid/gid for the bind-mounted dataDir to be writable and for the
  # files to be shareable.
  downloadUid = config.users.users.download.uid;
  downloadGid = config.users.groups.download.gid;
in {
  imports = [
    ../wireguard/euer/omo-ipfs-netns.nix
  ];

  sops.secrets."torrent-auth" = {
    owner = "nginx";
    sopsFile = ../../secrets/torrent.yaml;
  };

  # The host `download` user/group (2configs/share/default.nix, imported on
  # omo) already owns the shared media tree; just make sure the finished
  # directory exists with that owner so the container can write into it.
  systemd.tmpfiles.settings."10-torrent-data" = {
    "${dataDir}".d = {
      user = "download";
      group = "download";
      mode = "0775";
    };
  };

  containers.torrent = {
    autoStart = true;
    privateNetwork = false;
    extraFlags = [
      "--network-namespace-path=/run/netns/${netns}"
      "--resolv-conf=off"
    ];
    bindMounts = {
      "${dataDir}" = {
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

      networking.useDHCP = false;
      networking.useHostResolvConf = false;
      networking.firewall.enable = false;
      systemd.network.enable = false;

      # Recreate the host `download` user/group inside the container with the
      # exact same uid/gid (nspawn maps uids 1:1), so the bind-mounted dataDir
      # is writable and finished files carry the shared download ownership.
      # services.rtorrent only auto-creates its user when user == "rtorrent",
      # so for user == "download" we must define it ourselves.
      users.groups.download.gid = downloadGid;
      users.users.download = {
        uid = downloadUid;
        group = "download";
        isSystemUser = true;
        description = "shared download owner";
      };

      services.rtorrent = {
        enable = true;
        port = peer-port;
        user = "download";
        group = "download";
        dataPermissions = "0775";
        # rtorrent state (session/log/watch) lives in the container rootfs,
        # which persists across restarts; only finished downloads go to the
        # bind-mounted media tree.
        dataDir = "/var/lib/rtorrent";
        downloadDir = dataDir;
        configText = ''
          schedule2 = watch_start, 10, 10, ((load.start, (cat, (cfg.watch), "*.torrent")))
          network.http.max_open.set = 16
          network.xmlrpc.size_limit.set = 16M
        '';
      };

      services.flood = {
        enable = true;
        host = floodHost;
        port = web-port;
        extraArgs = [ "--rtsocket=${config.services.rtorrent.rpcSocket}" ];
      };

      # flood reaches rtorrent over its rpc socket, which the rtorrent rc
      # chowns to the download group with g+w — so flood must run as the
      # download user/group rather than its default DynamicUser.
      systemd.services.flood = {
        after = [ "rtorrent.service" ];
        serviceConfig = {
          DynamicUser = lib.mkForce false;
          User = "download";
          Group = "download";
        };
      };
    };
  };

  # Front flood on omo's host nginx. The vhost listens on omo's internal euer
  # addresses (plain http :80, like the other *.euer services) and proxies to
  # flood on the container's ULA. basicAuth guards the otherwise-open UI.
  services.nginx = {
    enable = true;
    virtualHosts."torrent.omo.euer" = {
      basicAuthFile = config.sops.secrets."torrent-auth".path;
      locations."/" = {
        proxyPass = "http://[${floodHost}]:${toString web-port}";
        proxyWebsockets = true;
      };
    };
  };

  # Wait for the cryptX mergerfs branches, netns and wg before the container
  # comes up. Require every branch explicitly (see ipfs/omo-container.nix:
  # media-cryptX.mount activates before its branches finish mounting).
  systemd.services."container@torrent" = {
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
