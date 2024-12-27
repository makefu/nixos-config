{config, ... }:
let
  port = 3011;
in
{
  services.nginx = {
    enable = lib.mkDefault true;
    virtualHosts."bookmark.euer.krebsco.de" = {
      useACMEHost = "euer.krebsco.de";
      # enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://omo.w:${toString port}";
        proxyWebsockets = true;
      };
    };
  };

}
