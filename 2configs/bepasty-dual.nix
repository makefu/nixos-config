{ config, lib, pkgs, ... }:

# 1systems should configure itself:
#   krebs.bepasty.servers.internal.nginx.listen  = [ "80" ]
#   krebs.bepasty.servers.external.nginx.listen  = [ "80" "443 ssl" ]
#     80 is redirected to 443 ssl

# secrets used:
#   wildcard.krebsco.de.crt
#   wildcard.krebsco.de.key
#   bepasty-secret.nix     <- contains single string

with lib;
{

  krebs.nginx.enable = mkDefault true;
  krebs.bepasty = {
    enable = true;
    serveNginx= true;

    servers = {
      internal = {
        nginx = {
          server-names = [ "paste.retiolum" "paste.${config.krebs.build.host.name}" ];
        };
        defaultPermissions = "admin,list,create,read,delete";
        secretKey = import <secrets/bepasty-secret.nix>;
      };

      external = {
        nginx = {
          server-names = [ "paste.krebsco.de" ];
          extraConfig = ''
            ssl_session_cache    shared:SSL:1m;
            ssl_session_timeout  10m;
            ssl_certificate     /root/secrets/wildcard.krebsco.de.crt;
            ssl_certificate_key /root/secrets/wildcard.krebsco.de.key;
            ssl_verify_client off;
            proxy_ssl_session_reuse off;
            ssl_protocols        TLSv1 TLSv1.1 TLSv1.2;
            ssl_ciphers RC4:HIGH:!aNULL:!MD5;
            ssl_prefer_server_ciphers on;
            if ($scheme = http){
              return 301 https://$server_name$request_uri;
          }'';
        };
        defaultPermissions = "read";
        secretKey = import <secrets/bepasty-secret.nix>;
      };
    };
  };
}
