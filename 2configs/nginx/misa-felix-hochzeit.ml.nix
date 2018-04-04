{ config, lib, pkgs, ... }:
{
  services.nginx = {
    enable = lib.mkDefault true;
    virtualHosts."misa-felix-hochzeit.ml" = {
      serverAliases = [ "www.misa-felix-hochzeit.ml" "misa-felix.ml" "www.misa-felix.ml" ];
      forceSSL = true;
      enableACME = true;
      locations = {
        "/" = {
          index = "index.html";
          root =  "/var/www/misa-felix-hochzeit.ml";
        };
      };
    };
  };
}
