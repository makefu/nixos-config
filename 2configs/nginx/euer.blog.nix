{ config, lib, pkgs, ... }:

with lib;
let
  ssl_cert = "/root/secrets/wildcard.krebsco.de.crt";
  ssl_key  = "/root/secrets/wildcard.krebsco.de.key";
  hostname = krebs.build.host.name;
in {
  krebs.nginx = {
    enable = mkDefault true;
    servers = {
      euer-blog = {
        listen = [ "80" "443 ssl" ];
        server-names = [ "euer.krebsco.de" "euer.blog.krebsco.de" "blog.${hostname}" ];
        extraConfig = ''
          gzip on;
          gzip_buffers 4 32k;
          gzip_types  text/plain application/x-javascript text/css;
          ssl_certificate ${ssl_cert};
          ssl_certificate_key ${ssl_key};
          default_type text/plain;
        '';
        locations = singleton (nameValuePair "/" ''
          root /var/www/euer.blog/;
        '');
      };
    };
  };
}
