{config, ... }:
{
  services.nginx = {
    enable = lib.mkDefault true;
    virtualHosts."work.euer.krebsco.de" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://omo.r:28981";
        proxyWebsockets = true;
      };
    };
  };

}
