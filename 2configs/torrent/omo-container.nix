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

  # Stable uid/gid so the bind-mounted dataDir is owned by the same id on
  # host and inside the container (systemd-nspawn maps uids 1:1 here).
  # rtorrent has no nixpkgs-reserved id; 392 is unused on omo (391 = radicle).
  rtorrentUid = 392;
  rtorrentGid = 392;
in {
  imports = [
    ../wireguard/euer/omo-ipfs-netns.nix
  ];

  sops.secrets."torrent-auth" = {
    owner = "nginx";
    sopsFile = ../../secrets/torrent.yaml;
  };

  # Host-side rtorrent user/group: only purpose is to give the bind-mounted
  # download directory a stable owner matching the in-container rtorrent user.
  users.users.rtorrent = {
    isSystemUser = true;
    group = "rtorrent";
    uid = rtorrentUid;
    description = "rtorrent data owner (host side)";
  };
  users.groups.rtorrent.gid = rtorrentGid;

  systemd.tmpfiles.settings."10-torrent-data" = {
    "${dataDir}".d = {
      user = "rtorrent";
      group = "rtorrent";
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

      # Pin uid/gid to match the host bind-mount owner.
      users.users.rtorrent.uid = lib.mkForce rtorrentUid;
      users.groups.rtorrent.gid = lib.mkForce rtorrentGid;

      services.rtorrent = {
        enable = true;
        port = peer-port;
        group = "rtorrent";
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
      # chowns to the rtorrent group with g+w — so flood must run as the
      # rtorrent user/group rather than its default DynamicUser.
      systemd.services.flood = {
        after = [ "rtorrent.service" ];
        serviceConfig = {
          DynamicUser = lib.mkForce false;
          User = "rtorrent";
          Group = "rtorrent";
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
