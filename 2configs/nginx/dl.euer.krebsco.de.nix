{ config, lib, pkgs, ... }:

{
  sops.secrets."dl.euer.krebsco.de-auth" = {};
  sops.secrets."dl.gum-auth" = {};
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
        basicAuthFile = config.sops.secrets."dl.euer.krebsco.de-auth".path;
    };
    virtualHosts."dl.gum.r" = {
        serverAliases = [ "dl.gum" "dl.makefu.r" "dl.makefu" ];
        root = config.makefu.dl-dir;
        extraConfig = "autoindex on;";
        basicAuthFile = config.sops.secrets."dl.gum-auth".path;
    };
  };
}
