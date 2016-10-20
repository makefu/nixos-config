{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
let
  hostname = config.krebs.build.host.name;
  external-ip = config.krebs.build.host.nets.internet.ip4.addr;
in {
  krebs.nginx = {
    enable = mkDefault true;
    servers = {
      update-connector-one = {
        listen = [ "${external-ip}:80" ];
        server-names = [
          "update.connector.one"
          "firmware.connector.one"
        ];
        locations = singleton (nameValuePair "/" ''
          autoindex on;
          root /var/www/update.connector.one;
          sendfile on;
          gzip on;
        '');
      };
    };
  };
}
