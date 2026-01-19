{ config, lib, pkgs, ... }:
# more than just nginx config but not enough to become a module
let
	port = 8000;
	domain = "plan.binaergewitter.de";
in {
  sops.secrets.bgt-datefinder-env = {};
  #services.redis.enable = true;
  systemd.services.datefinder = {
    description = "Datefinder Server (bgt)";
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    environment = {
        #REDIS_URL = "redis://localhost:6379/0";
		SITE_URL=   "https://${domain}";
		ALLOWED_HOSTS=domain;
		USE_X_FORWARDED_HOST="true";
		TRUST_PROXY_HEADERS="true";
    };
    script = ''
        set -x
        . "$CREDENTIALS_DIRECTORY/config"
        export KEYCLOAK_SERVER_URL KEYCLOAK_REALM KEYCLOAK_CLIENT_ID KEYCLOAK_CLIENT_SECRET SECRET_KEY
        "${pkgs.datefinder}/bin/datefinder-server" migrate
        "${pkgs.datefinder}/bin/datefinder-server"
    '';
    serviceConfig = {
      LoadCredential = [
          "config:${config.sops.secrets.bgt-datefinder-env.path}"
      ];
      Restart = "always";
      RestartSec = "60s";
      DynamicUser = true;
      StateDirectory = "datefinder";
      WorkingDirectory = "/var/lib/datefinder";
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
  };
}
