{
  makefu.netdata = {
    enable = true;
    stream.role = "master";
  };

  services.nginx = {
    virtualHosts."netdata.euer.krebsco.de" = {
      addSSL = true;
      enableACME = true;
      locations."/".proxyPass = "http://localhost:19999";
    };
    virtualHosts."netdata.makefu.r" = {
      locations."/".proxyPass = "http://localhost:19999";
    };
  };
}
