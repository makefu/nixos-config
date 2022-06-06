{ config, lib, pkgs, ... }:

let
  basicAuth = import <torrent-secrets/auth.nix>;
  peer-port = 51412;
  web-port = 8112;
  daemon-port = 58846;
  dldir = config.makefu.dl-dir;
in {
  services.rtorrent = {
    enable = true;
    user = "rtorrent";
    port = peer-port;
    openFirewall = true;
    group = "download";
    downloadDir = dldir;
    configText = ''
      schedule2 = watch_start, 10, 10, ((load.start, (cat, (cfg.watch), "/media/cloud/watch/*.torrent")))
    '';
  };

  systemd.services.flood = {
    wantedBy = [ "multi-user.target" ];
    wants = [ "rtorrent.service" ];
    after = [ "rtorrent.service" ];
    serviceConfig = {
      User = "rtorrent";
      ExecStart = "${pkgs.nodePackages.flood}/bin/flood --auth none --port ${toString web-port} --rtsocket ${config.services.rtorrent.rpcSocket}";
    };
  };

  #security.acme.certs."torrent.${config.krebs.build.host.name}.r".server = config.krebs.ssl.acmeURL;

  services.nginx = {
    enable = true;
    virtualHosts."torrent.${config.krebs.build.host.name}.r" = {
      # TODO
      inherit basicAuth;
      #enableACME = true;
      #addSSL = true;
      root = "${pkgs.nodePackages.flood}/lib/node_modules/flood/dist/assets";
      locations."/api".extraConfig = ''
        proxy_pass       http://localhost:${toString web-port};
      '';
      locations."/".extraConfig = ''
        try_files $uri /index.html;
      '';
    };
  };
}
