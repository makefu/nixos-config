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
  secKey = import <secrets/bepasty-secret.nix>;
  acmepath = "/var/lib/acme/";
  acmechall = acmepath + "/challenges/";
  ext-dom = "paste.krebsco.de" ;
in {

  krebs.nginx.enable = mkDefault true;
  krebs.bepasty = {
    enable = true;
    serveNginx= true;

    servers = {
      internal = {
        nginx = {
          server-names = [ "paste.retiolum" "paste.r" "paste.${config.krebs.build.host.name}" ];
        };
        defaultPermissions = "admin,list,create,read,delete";
        secretKey = secKey;
      };

      external = {
        nginx = {
          server-names = [ ext-dom ];
          ssl = {
            enable = true;
            certificate = "${acmepath}/${ext-dom}/fullchain.pem";
            certificate_key = "${acmepath}/${ext-dom}/key.pem";
            # these certs will be needed if acme has not yet created certificates:
            #certificate =   "${sec}/wildcard.krebsco.de.crt";
            #certificate_key = "${sec}/wildcard.krebsco.de.key";
            ciphers = "RC4:HIGH:!aNULL:!MD5" ;
            force_encryption = true;
          };
          locations = singleton ( nameValuePair  "/.well-known/acme-challenge" ''
            root ${acmechall}/${ext-dom}/;
          '');
          extraConfig = ''
          ssl_session_cache    shared:SSL:1m;
          ssl_session_timeout  10m;
          ssl_verify_client off;
          proxy_ssl_session_reuse off;
          '';
        };
        defaultPermissions = "read";
        secretKey = secKey;
      };
    };
  };
  security.acme.certs."${ext-dom}" = {
    email = "acme@syntax-fehler.de";
    webroot = "${acmechall}/${ext-dom}/";
    group = "nginx";
    allowKeysForGroup = true;
    postRun = "systemctl reload nginx.service";
    extraDomains."${ext-dom}" = null ;
  };
}
