{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
let
  hostname = config.krebs.build.host.name;
  user = config.services.nginx.user;
  group = config.services.nginx.group;
  external-ip = config.krebs.build.host.nets.internet.ip4.addr;
  internal-ip = config.krebs.build.host.nets.retiolum.ip4.addr;
in {
  services.nginx = {
    enable = mkDefault true;
    virtualHosts."share.euer.krebsco.de" = {
      locations."/" =  {
        proxyPass = "http://localhost:8000/";
        extraConfig = ''
          proxy_set_header   Host $host;
          proxy_set_header   X-Real-IP          $remote_addr;
          proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        '';
      };
    };
  };
}
