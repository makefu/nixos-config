{ config, lib, pkgs, ... }:

let
  peer-port = 51412;
  web-port = 8112;
  daemon-port = 58846;
  dldir = config.makefu.dl-dir;
in {
  services.rtorrent = {
    enable = true;
    user = "rtorrent";
    port = peer-port;
    package = pkgs.jesec-rtorrent;
    openFirewall = true;
    group = "download";
    downloadDir = dldir;
    configText = ''
      schedule2 = watch_start, 10, 10, ((load.start, (cat, (cfg.watch), "/media/cloud/watch/*.torrent")))
    '';
  };
  services.flood = {
    enable = true;
    port = web-port;
    extraArgs = ["--auth=none" "--rtsocket=${config.services.rtorrent.rpcSocket}"];
  };
  # allow access to the socket
  systemd.services.flood.serviceConfig.SupplementaryGroups = [ "download" ];

  #security.acme.certs."torrent.${config.krebs.build.host.name}.r".server = config.krebs.ssl.acmeURL;
  sops.secrets."torrent-auth" = {
    owner = "nginx";
    sopsFile = ../../secrets/torrent.yaml;
  };
  services.nginx = {
    enable = true;
    virtualHosts."torrent.${config.krebs.build.host.name}.r" = {
      basicAuthFile = config.sops.secrets."torrent-auth".path;
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
