let
    port = 5000;
in {
    services.changedetection-io = {
        enable = true;
        webDriverSupport = true;
        playwrightSupport = true;
        listenAddress = "0.0.0.0";
        inherit port;
        baseURL = "http://change.lan:${ toString port }";
    };
}
