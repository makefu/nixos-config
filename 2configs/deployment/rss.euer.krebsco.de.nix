{ pkgs, lib, config, ... }:
let
  fqdn = "rss.euer.krebsco.de";
in {
  services.tt-rss = {
    enable = true;
    virtualHost = fqdn;
    selfUrlPath = "https://${fqdn}";
  };

  services.postgresql.package = pkgs.postgresql_9_6;
  state = [ config.services.postgresqlBackup.location ];

  services.postgresqlBackup = {
    enable = true;
    databases = [ config.services.tt-rss.database.name ];
  };

  services.nginx.virtualHosts."${fqdn}" = {
    enableACME = true;
    forceSSL = true;
  };
}

