{ pkgs, lib, config, ... }:
let
  fqdn = "rss.euer.krebsco.de";
in {
  services.tt-rss = {
    enable = true;
    virtualHost = fqdn;
    selfUrlPath = "https://${fqdn}";
  };
  systemd.services.tt-rss.serviceConfig.ExecStart = lib.mkForce "${pkgs.php}/bin/php /var/lib/tt-rss/update_daemon2.php";
  services.postgresql.package = pkgs.postgresql_9_6;
  state = [ config.services.postgresql.dataDir ];
  services.nginx.virtualHosts."${fqdn}" = {
    enableACME = true;
    forceSSL = true;
  };
}

