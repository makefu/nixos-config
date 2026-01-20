{ config, lib, pkgs, ... }:
# more than just nginx config but not enough to become a module
let
	port = 8000;
    domain = "plan.binaergewitter.de";
    calendar-path = "${statedir}/calendar.ics";
    name = "datefinder";
    statedir = "/var/lib/${name}";
in {
    sops.secrets.bgt-datefinder-env.restartUnits = [ "datefinder.service" ];
  #services.redis.enable = true;

  # prepare user and access to calendar
  users.users.${name} = {
      isSystemUser = true;
      group = name;
      home = statedir;
      createHome = false;
  };
  users.groups.${name} = {};
  users.users.nginx.extraGroups = [ name ];
  systemd.tmpfiles.settings."01-${name}-dirs"."${statedir}".d = {
    user = name;
    mode = "0750";
    group = name;
  };

  systemd.services.${name} = {
    description = "Datefinder Server (bgt)";
    after = [ "network-online.target" ];
    environment = {
        #REDIS_URL = "redis://localhost:6379/0";
		SITE_URL=   "https://${domain}";
		ALLOWED_HOSTS = domain;
		USE_X_FORWARDED_HOST="true";
        TRUST_PROXY_HEADERS="true";
        LOCAL_LOGIN_ENABLED = "false";
        APPRISE_UNCONFIRM_TEMPLATE="Podcast {{ date_formatted }} wurde abgesagt";
        APPRISE_CONFIRM_TEMPLATE="{{ description }}";
        STATEDIR = statedir;
        ICAL_EXPORT_PATH = calendar-path;
        #REGISTRATION_ENABLED = "false";
    };
    script = ''
        set -x
        . "$CREDENTIALS_DIRECTORY/config"
        export KEYCLOAK_SERVER_URL KEYCLOAK_REALM KEYCLOAK_CLIENT_ID KEYCLOAK_CLIENT_SECRET SECRET_KEY DEBUG APPRISE_URLS
        "${pkgs.datefinder}/bin/datefinder-server" migrate
        "${pkgs.datefinder}/bin/datefinder-server"
    '';
    serviceConfig = {
      LoadCredential = [
          "config:${config.sops.secrets.bgt-datefinder-env.path}"
      ];
      Restart = "always";
      RestartSec = "60s";
      User = name;
      WorkingDirectory = statedir;
      PrivateTmp = true;
    };
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
