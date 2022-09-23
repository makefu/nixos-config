{ config, lib, pkgs, ... }:

let
  hostname = config.krebs.build.host.name;
  user = config.services.nginx.user;
  group = config.services.nginx.group;
  external-ip = config.krebs.build.host.nets.internet.ip4.addr;
  internal-ip = config.krebs.build.host.nets.retiolum.ip4.addr;
in {
  services.nginx = {
    enable = lib.mkDefault true;
    virtualHosts."music.euer.krebsco.de" = {
      forceSSL = true;
      enableACME = true;
      locations."/" =  {
        proxyPass = "http://omo:4533/";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header   Host $host;
          proxy_set_header   X-Real-IP          $remote_addr;
          proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        '';
      };
    };
  };
}
