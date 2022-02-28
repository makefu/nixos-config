{ config, lib, pkgs, ... }:

with import <stockholm/lib>;

let
  basicAuth = import <torrent-secrets/auth.nix>;
  peer-port = 51412;
  web-port = 8112;
  daemon-port = 58846;
  base-dir = config.krebs.rtorrent.workDir;
in {

  users.users = {
    download = {
      name = "download";
      home = base-dir;
      uid = mkDefault (genid "download");
      createHome = true;
      useDefaultShell = true;
      group = "download";
      openssh.authorizedKeys.keys = [ ];
    };
  };

  users.extraGroups = {
    download = {
      gid = lib.mkDefault (genid "download");
      members = [
        config.krebs.build.user.name
        "download"
        "rtorrent"
        "nginx"
      ];
    };
    rtorrent.members = [ "download" ];
  };

  krebs.rtorrent = let
    d = config.makefu.dl-dir;
  in {
    enable = true;
    web = {
      enable = true;
      port = web-port;
      inherit basicAuth;
    };
    rutorrent.enable = true;
    enableXMLRPC = true;
    listenPort = peer-port;
    downloadDir = d + "/finished/incoming";
    watchDir = d + "/watch";
    # TODO: maybe test out multiple watch dirs with tags: https://github.com/rakshasa/rtorrent/wiki/TORRENT-Watch-directories
    extraConfig = ''
      # log.add_output = "debug", "rtorrent-systemd"
      # log.add_output = "dht_debug", "rtorrent-systemd"
      # log.add_output = "tracker_debug", "rtorrent-systemd"
      log.add_output = "rpc_events", "rtorrent-systemd"
      # log.add_output = "rpc_dump", "rtorrent-systemd"
      system.daemon.set = true
    '';
    # dump old torrents into watch folder to have them re-added
  };

  services.nginx.virtualHosts."torrent.${config.krebs.build.host.name}.r".locations."/" = { proxyPass = "http://localhost:${toString web-port}/"; };

  networking.firewall.extraCommands = ''
    iptables -A INPUT -i retiolum -p tcp --dport ${toString web-port} -j ACCEPT
  '';

  networking.firewall.allowedTCPPorts = [ peer-port ];
  networking.firewall.allowedUDPPorts = [ peer-port ];
  state = [ config.krebs.rtorrent.sessionDir ]; # state which torrents were loaded
}
