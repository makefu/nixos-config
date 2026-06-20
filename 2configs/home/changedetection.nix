let
    port = 5000; # 
in {
    services.changedetection-io = {
        enable = true;
        webDriverSupport = true;
        #playwrightSupport = true;
        listenAddress = "0.0.0.0";
        inherit port;
        baseURL = "http://change.euer";
    };

  services.nginx.virtualHosts."change" = {
    serverAliases = [
      "change.euer"
      "change.lan"
    ];

    locations."/" = {
      proxyPass = "http://localhost:${toString port}";
      proxyWebsockets = true;
    };
  };
}
