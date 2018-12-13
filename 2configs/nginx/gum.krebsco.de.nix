{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
let
in {
  services.nginx = {
    enable = mkDefault true;
    virtualHosts."gum.krebsco.de" = {
      forceSSL = true;
      enableACME = true;
      locations."/" =  {
        # proxyPass = "http://localhost:8000/";
        # extraConfig = ''
        #   proxy_set_header   Host $host;
        #   proxy_set_header   X-Real-IP          $remote_addr;
        #   proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        # '';
      };
    };
  };
}
