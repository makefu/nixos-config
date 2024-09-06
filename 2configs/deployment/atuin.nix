{
  services.atuin = {
    enable = true;
    maxHistory = 900001;
  };
  services.postgresql.enable = true;
  services.nginx.virtualHosts."atuin.euer.krebsco.de" = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://localhost:${config.services.atuin.port}";
  };
}
