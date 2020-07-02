{ pkgs, config, ... }:
let
  fqdn = "rss.euer.krebsco.de";
in {
  services.tt-rss = {
    enable = true;
    virtualHost = fqdn;
    selfUrlPath = "https://${fqdn}";
  };
  services.postgresql.package = pkgs.postgresql_9_6;
  state = [ config.services.postgresql.dataDir ];
  services.nginx.virtualHosts."${fqdn}" = {
    enableACME = true;
    forceSSL = true;
  };
}

