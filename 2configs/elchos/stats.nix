{ config, lib, pkgs, ... }:

# requires nsupdate to get correct hostname (from ./search.nix)
# graphite-web on port 8080
# carbon cache on port 2003 (tcp/udp)

with import <stockholm/lib>;
{

  services.nginx = {
    enable = mkDefault true;
    virtualHosts = {
      "stats.nsupdate.info" = {
        enableACME = true;
        forceSSL = true;

        locations = {
          "/"  = {
            proxyPass  = "http://localhost:3000/";
            extraConfig = ''
              proxy_set_header   Host             $host;
              proxy_set_header   X-Real-IP        $remote_addr;
              proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
            '';
          };
        };
      };
    };
  };

  services.grafana = {
    enable = true;
    addr = "127.0.0.1";
    users.allowSignUp = false;
    users.allowOrgCreate = false;
    users.autoAssignOrg = false;
    auth.anonymous.enable = true;
    security = import <secrets/grafana_security.nix>; # { AdminUser = ""; adminPassword = ""}
  };

  services.graphite = {
    api = {
      enable = true;
      listenAddress = "127.0.0.1";
      port = 18080;
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
        retentions = 10s:30d,60s:3y

        [default]
        pattern = .*
        retentions = 30s:30d,300s:1y
        '';
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 2003 80 443 ];
    allowedUDPPorts = [ 2003 ];
  };
}
