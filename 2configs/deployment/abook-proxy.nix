{config, ... }:
let
  port = 3009;
  domain = "abook.euer.krebsco.de";
in
  {
  security.acme.certs."euer.krebsco.de".extraDomainNames = [domain];
  services.nginx = {
    virtualHosts."${domain}" = {
      useACMEHost = "euer.krebsco.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://omo.w:${toString port}";
        # proxyWebsockets = true;
      };
    };
  };

}
