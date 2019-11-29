{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
{
  services.nginx = {
    enable = mkDefault true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    virtualHosts."dl.euer.krebsco.de" = {
        root = config.makefu.dl-dir;
        extraConfig = "autoindex on;";
        forceSSL = true;
        enableACME = true;
        basicAuth = import <secrets/dl.euer.krebsco.de-auth.nix>;
    };
  };
}
