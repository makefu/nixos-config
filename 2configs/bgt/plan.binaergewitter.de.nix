{ config, lib, pkgs, inputs, ... }:
# more than just nginx config but not enough to become a module
let
	port = 8000;
  domain = "plan.binaergewitter.de";
  calendar-path = "${config.services.datefinder.stateDir}/calendar.ics";
  name = "datefinder";
  statedir = "/var/lib/${name}";
in {
  imports = [
      inputs.datefinder.nixosModules.datefinder
    ];
  sops.secrets.bgt-datefinder-env.restartUnits = [ "datefinder.service" ];
  services.datefinder = {
    enable = true;
    group = "nginx"; # allow nginx to read calendar.ics
    settings = {
      allowedHosts = [ "plan.binaergewitter.de" "localhost" ];
      registrationEnabled = false;
      localLoginEnabled = false;
      useXForwardedHost = true;
      trustProxyHeaders = true;
      siteUrl = "https://plan.binaergewitter.de";
      redisUrl = "redis://localhost:6379";
      icalTimezone = "Europe/Berlin";
      csrfTrustedOrigins = [ "https://plan.binaergewitter.de" ];
    };
    #database = {
    #  type = "postgres";
    #  createLocally = true;
    #};
    environmentFile = config.sops.secrets.bgt-datefinder-env.path;
  };
  services.redis.servers.datefinder = {
    enable = true;
    port = 6379;
  };
  services.nginx.virtualHosts."${domain}" = {
    # useACMEHost = "euer.krebsco.de";
    locations."/" = {
        proxyPass = "http://127.0.0.1:${toString port}";
        #basicAuthFile = config.sops.secrets.etherpad_htpasswd.path;
        extraConfig = ''
            proxy_set_header  Upgrade $http_upgrade;
            proxy_set_header  Connection "upgrade";
            proxy_read_timeout 1799s;
        '';
    };
    locations."= /calendar/export/calendar.ics" = {
        alias = calendar-path;

        extraConfig = ''
          default_type text/calendar;
          limit_except GET { deny all; }
          access_log off;
          add_header Cache-Control "no-cache";
        '';
      };
  };
}
