{ config, pkgs, ... }:
let
  base = config.makefu.dl-dir;
  daemon-port = 58846;
  peer-port = 51412;
  web-port = 8112;
  secfile = toString <torrent-secrets> + "/deluge-auth";
  authfile = config.services.deluge.dataDir + "/myauth";
in {
  services.deluge = {
    enable = true;
    package = pkgs.deluge-2_x;
    openFilesLimit = 65355;
    declarative = true;
    config = {
      download_location = base + "/finished";
      allow_remote = true;
      inherit daemon-port;
      listen_ports = [ peer-port ];
      copy_torrent_file = true;
      torrentfiles_location = base + "/torrents";
      max_active_seeding = 50;
      max_connections_global = 1000;
      max_half_open_connections = 200;
      enabled_plugins = [ "AutoAdd" ];
    };
    openFirewall = true;
    group = "download";
    authFile = authfile;
    web = {
      enable = true;
      port = web-port;
    };
  };

  #systemd.services.deluged.serviceConfig.ExecStartPre = pkgs.writeDash "install-auth" ''
  #  install -odeluge "$secfile" "$authfile"
  #'';
  services.nginx.enable = true;
  services.nginx.virtualHosts."torrent.${config.krebs.build.host.name}.r".locations."/" = { proxyPass = "http://localhost:${toString web-port}/"; };
  state = [ "/var/lib/deluge/.config/deluge" ];
}
