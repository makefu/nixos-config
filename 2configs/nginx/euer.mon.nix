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
    virtualHosts."mon.euer.krebsco.de" = let
        # flesh_wrap
        authFile = pkgs.writeText "influx.conf" ''
            user:$apr1$ZG9oQCum$FhtIe/cl3jf8Sa4zq/BWd1
          '';
    in {
      forceSSL = true;
      enableACME = true;
      locations."/" =  {
        proxyPass = "http://wbob.r:3000/";
        extraConfig = ''
          proxy_set_header   Host $host;
          proxy_set_header   X-Real-IP          $remote_addr;
          proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        '';
      };
      locations."/influxdb/"  = {
        proxyPass = "http://wbob.r:8086/";
        extraConfig = ''
            auth_basic       "Needs Autherization to visit";
            auth_basic_user_file ${authFile};
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_redirect off;
        '';
      };
    };
  };
}
