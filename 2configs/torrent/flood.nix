{lib,config, ... }:
let
  web-port = 8112;
in {
  sops.secrets."torrent-auth" = {
    owner = "nginx";
    sopsFile = ../../secrets/torrent.yaml;
  };
  services.flood = {
    enable = true;
    port = web-port;
    extraArgs = ["--rtsocket=${config.services.rtorrent.rpcSocket}"];
  };
  systemd.services.flood.serviceConfig = {
    SupplementaryGroups = [ "download" ];
    DynamicUser = lib.mkForce false;
    User = config.services.rtorrent.user;
  };
  services.nginx = {
    enable = true;
    virtualHosts."torrent.${config.krebs.build.host.name}.r" = {
      basicAuthFile = config.sops.secrets."torrent-auth".path;
      #root = "${pkgs.nodePackages.flood}/lib/node_modules/flood/dist/assets";
      #locations."/api".extraConfig = ''
      #  proxy_pass       http://localhost:${toString web-port};
      #'';
      #locations."/".extraConfig = ''
      #  try_files $uri /index.html;
      #'';
      locations."/".proxyPass = "http://localhost:${toString config.services.flood.port}";
    };
  };
}
