{ pkgs, lib, config, ... }:
let
  fqdn = "rss.euer.krebsco.de";
  ratt-path = "/var/lib/ratt/";
in {
  systemd.tmpfiles.rules = ["d ${ratt-path} 0750 nginx nginx - -" ];
  services.tt-rss = {
    enable = true;
    virtualHost = fqdn;
    selfUrlPath = "https://${fqdn}";
  };

  state = [ config.services.postgresqlBackup.location ];

  services.postgresqlBackup = {
    enable = true;
    databases = [ config.services.tt-rss.database.name ];
  };
  systemd.services.postgresqlBackup-tt_rss.serviceConfig.SupplementaryGroups = [ "download" ];

  services.nginx.virtualHosts."${fqdn}" = {
    enableACME = true;
    forceSSL = true;
    locations."/ratt/" = {
      alias = ratt-path;
      extraConfig = "autoindex on;";
    };
  };
}

