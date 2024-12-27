{config, lib, pkgs, ...}:
let
  web_port = 9011;
  statedir = "/var/lib/shiori";
in {
  state = [ "/var/lib/private/shiori" ]; # when using dynamicUser
  services.shiori = {
    enable = true;
    port = web_port;
    address = "127.0.0.1";
  };
  services.nginx.virtualHosts."bookmark.euer.krebsco.de" = {
    forceSSL = true;
    enableACME = true;

    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString web_port}/";
    };
  };
}
