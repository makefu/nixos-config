{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
{
  services.nginx = {
    enable = mkDefault true;
    virtualHosts."update.connector.one" = {
      locations = {
        "/" = {
          root =  "/var/www/update.connector.one";
          extraConfig = ''
            autoindex on;
            sendfile on;
            gzip on;
          '';
        };
      };
    };
  };
}
