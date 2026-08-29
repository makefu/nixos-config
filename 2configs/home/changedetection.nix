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

  # ships with loguru at DEBUG: every worker/queue tick is logged
  systemd.services.changedetection-io.environment.LOGGER_LEVEL = "WARNING";

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
