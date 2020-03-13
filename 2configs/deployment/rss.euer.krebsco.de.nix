let
  fqdn = "rss.euer.krebsco.de";
in {
  services.tt-rss = {
    enable = true;
    virtualHost = fqdn;
    selfUrlPath = "https://${fqdn}";
  };
  services.nginx.virtualHosts."${fqdn}" = {
    enableACME = true;
    forceSSL = true;
  };
}

