let
  fqdn = "board.euer.krebsco.de";
  port = 13113;
in {
  services.restya-board = {
    enable = true;
    virtualHost.listenPort = port;
  };
  services.nginx.virtualHosts."${fqdn}" = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://localhost:${toString port}";
  };
}

