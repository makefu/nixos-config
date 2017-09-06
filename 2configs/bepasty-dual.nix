{ config, lib, pkgs, ... }:

# 1systems should configure itself:
#   krebs.bepasty.servers.internal.nginx.listen  = [ "80" ]
#   krebs.bepasty.servers.external.nginx.listen  = [ "80" "443 ssl" ]
#     80 is redirected to 443 ssl

# secrets used:
#   wildcard.krebsco.de.crt
#   wildcard.krebsco.de.key
#   bepasty-secret.nix     <- contains single string

with import <stockholm/lib>;
let
  sec = toString <secrets>;
  # secKey is nothing worth protecting on a local machine
  secKey = "${secrets}/bepasty-secret";
  acmepath = "/var/lib/acme/";
  acmechall = acmepath + "/challenges/";
  ext-dom = "paste.krebsco.de" ;
in {

  services.nginx.enable = mkDefault true;
  krebs.bepasty = {
    enable = true;
    serveNginx= true;

    servers = {
      "paste.r" = {
        nginx = {
          serverAliases = [ "paste.retiolum" "paste.${config.krebs.build.host.name}" ];
        };
        defaultPermissions = "admin,list,create,read,delete";
        secretKeyFile = secKey;
      };

      "${ext-dom}" = {
        nginx = {
          forceSSL = true;
          enableACME = true;
        };
        defaultPermissions = "read";
        secretKeyFile = secKey;
      };
    };
  };
}
