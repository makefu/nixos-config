{ config, lib, pkgs, ... }:

with config.krebs.lib;
let
  hostname = config.krebs.build.host.name;
  external-ip = head config.krebs.build.host.nets.internet.addrs4;
in {
  krebs.nginx = {
    enable = mkDefault true;
    servers = {
      omo-share = {
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
