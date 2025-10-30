{ pkgs, ... }:
{
    services.nginx.virtualHosts."element.euer.krebsco.de" = {
        forceSSL = true;
        enableACME = true;

    root = pkgs.element-web.override {
      conf = {
        default_server_config."m.homeserver".base_url  = "https://matrix.euer.krebsco.de"; # see `clientConfig` from the snippet above.
      };
    };
  };
 # für die tls terminierung und weiterleitung nach wozzy
    services.nginx.virtualHosts."matrix.4ce.de.gts" = {
    forceSSL = true;
        enableACME = true;


    locations."/" = {
      proxyPass = "http://omo.w:6167";
      proxyWebsockets = true;
    };
};
}
