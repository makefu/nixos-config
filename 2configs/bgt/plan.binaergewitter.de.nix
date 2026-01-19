{ config, lib, pkgs, ... }:
# more than just nginx config but not enough to become a module
let
  port = 8672;
in {
  sops.secrets.bgt-datefinder-env = {};
  services.redis.enable = true;
  systemd.services.datefinder = {
    description = "Datefinder Server (bgt)";
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    environment = {
        REDIS_URL = "redis://localhost:6379/0";
    };
    environmentFile = config.sops.secrets.datefinder-env.path;
    serviceConfig = {
      Restart = "always";
      RestartSec = "60s";
      DynamicUser = true;
      StateDirectory = "datefinder";
      WorkingDirectory = "/var/lib/datefinder";

      ExecStart = "${pkgs.date-finder}/bin/datefinder-server";
      PrivateTmp = true;
    };
  };
  services.nginx.virtualHosts."plan.binaergewitter.de" = {
    # useACMEHost = "euer.krebsco.de";
    enableACME = true;
    forceSSL = true;
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
