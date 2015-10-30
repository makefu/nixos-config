{ config, lib, pkgs, ... }:

with lib;
let
  sec = toString <secrets>;
  ssl_cert = "${sec}/wildcard.krebsco.de.crt";
  ssl_key  = "${sec}/wildcard.krebsco.de.key";
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
