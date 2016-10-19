{ config, lib, pkgs, ... }:

# graphite-web on port 8080
# carbon cache on port 2003 (tcp/udp)
with config.krebs.lib;
let
  sec = toString <secrets>;
  acmepath = "/var/lib/acme/";
  acmechall = acmepath + "/challenges/";
  ext-dom = "stats.nsupdate.info";
  #ssl_cert = "${sec}/wildcard.krebsco.de.crt";
  #ssl_key  = "${sec}/wildcard.krebsco.de.key";
  ssl_cert = "${acmepath}/${ext-dom}/fullchain.pem";
  ssl_key = "${acmepath}/${ext-dom}/key.pem";
in {
  networking.firewall = {
    allowedTCPPorts = [ 2003 80 443 ];
    allowedUDPPorts = [ 2003 ];
  };

  services.grafana = {
    enable = true;
    addr = "127.0.0.1";
    extraOptions = { "AUTH_ANONYMOUS_ENABLED" = "true"; };
    users.allowSignUp = false;
    users.allowOrgCreate = false;
    users.autoAssignOrg = false;
    security = import <secrets/grafana_security.nix>; # { AdminUser = ""; adminPassword = ""}
  };
  krebs.nginx = {
    enable = true;
    servers.elch-stats = {
      server-names = [ ext-dom ];
      listen = [ "80" "443 ssl" ];
      ssl = {
          enable = true;
          # these certs will be needed if acme has not yet created certificates:
          certificate =   ssl_cert;
          certificate_key = ssl_key;
          force_encryption = true;
      };

      locations = [
          (nameValuePair "/" ''
            proxy_set_header   Host $host;
            proxy_set_header   X-Real-IP          $remote_addr;
            proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass http://localhost:3000/;
          '')
          (nameValuePair  "/.well-known/acme-challenge" ''
            root ${acmechall}/${ext-dom}/;
          '')
      ];
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

  services.graphite = {
    web = {
      enable = true;
      host = "127.0.0.1";
      port = 8080;
    };
    carbon = {
      enableCache = true;
      # save disk usage by restricting to 1 bulk update per second
      config = ''
        [cache]
        MAX_CACHE_SIZE = inf
        MAX_UPDATES_PER_SECOND = 1
        MAX_CREATES_PER_MINUTE = 500
        '';
      storageSchemas = ''
        [carbon]
        pattern = ^carbon\.
        retentions = 60:90d

        [elchos]
        patterhn = ^elchos\.
        retention = 10s:30d,60s:1y

        [default]
        pattern = .*
        retentions = 30s:30d,300s:1y
        '';
    };
  };
}
