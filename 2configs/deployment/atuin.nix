{ config, ... }:{
  services.atuin = {
    enable = true;
    maxHistoryLength = 900001;
    database.createLocally = true;
    # openRegistration = true;
  };
  services.postgresql.enable = true;
  services.nginx.virtualHosts."atuin.euer.krebsco.de" = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://localhost:${toString config.services.atuin.port}";
  };
}
