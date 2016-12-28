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
    beacon = {
      enable = true;
      config = {
        graphite_url = "http://localhost:18080";

        no_data = "critical";
        loading_error = "normal";

        prefix = "[elchos]";

        cli = {
          command = ''${pkgs.irc-announce}/bin/irc-announce irc.freenode.org 6667 alert0r \#elchos ' [elchos] ''${level} ''${name} ''${value}' '';
        };
        #smtp = {
        #  from = "beacon@mors.r";
        #  to = [
        #    "lass@mors.r"
        #  ];
        #};
        normal_handlers = [
          # "smtp"
          "cli"
        ];
        warning_handlers = [
          # "smtp"
          "cli"
        ];
        critical_handlers = [
          # "smtp"
          "cli"
        ];
        alerts = let
          high-load = hostid: let
              host = "elch-${toString hostid}"; in {
              name = "high-cpu-load-${host}";
              query = "aliasByNode(perSecond(elchos.${host}.cpu.0.cpu.idle),1)";
              method = "average";
              interval = "1minute";
              logging = "info";
              repeat_interval = "5minute";
              rules = [
  #              "warning: < 30.0"
                "critical: < 1.0"
              ];
            };
          in map high-load [ 1 2 3 4 5 6 7 8 ];
      };
   };
   api = {
      enable = true;
      package = pkgs.graphiteApi;
      listenAddress = "127.0.0.1";
      port = 18080;
    };
    carbon = {
      enableCache = true;
      # save disk usage by restricting to 1 bulk update per second
      config = ''
        [cache]
        MAX_CACHE_SIZE = inf
        MAX_UPDATES_PER_SECOND = 10
        MAX_CREATES_PER_MINUTE = 5000
        '';
      storageSchemas = ''
        [carbon]
        pattern = ^carbon\.
        retentions = 60:90d

        [elchos]
        patterhn = ^elchos\.
        retentions = 10s:30d,60s:3y


        [default]
        pattern = ^krebs\.
        retentions = 1s:30d,30s:3m,300s:1y
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
