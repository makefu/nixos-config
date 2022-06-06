{ config, lib, pkgs, ... }:

{
  users.groups.download.members = [ "nginx" ];
  services.nginx = {
    enable = lib.mkDefault true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    virtualHosts."dl.euer.krebsco.de" = {
        root = config.makefu.dl-dir;
        extraConfig = "autoindex on;";
        forceSSL = true;
        enableACME = true;
        basicAuth = import <secrets/dl.euer.krebsco.de-auth.nix>;
    };
    virtualHosts."dl.gum.r" = {
        serverAliases = [ "dl.gum" "dl.makefu.r" "dl.makefu" ];
        root = config.makefu.dl-dir;
        extraConfig = "autoindex on;";
        basicAuth = import <secrets/dl.gum-auth.nix>;
    };
  };
}
