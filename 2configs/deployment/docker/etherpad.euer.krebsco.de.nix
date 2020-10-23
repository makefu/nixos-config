{ lib, ... }:
let
  port = 19201;
in {
  #services.nginx.virtualHosts."euer.krebsco.de".serverAliases = [ "etherpad.euer.krebsco.de" ];
  services.nginx.virtualHosts."etherpad.euer.krebsco.de" = {
    # useACMEHost = "euer.krebsco.de";
    extraConfig = ''
      ssl_session_timeout  5m;
    '';
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://localhost:${toString port}";
    # from https://github.com/ether/etherpad-lite/wiki/How-to-put-Etherpad-Lite-behind-a-reverse-Proxy
    locations."/".extraConfig = ''

        proxy_buffering    off; # be careful, this line doesn't override any proxy_buffering on set in a conf.d/file.conf
        proxy_set_header   Host $host;
        proxy_pass_header  Server;

        # Note you might want to pass these headers etc too.
        proxy_set_header    X-Real-IP $remote_addr; # https://nginx.org/en/docs/http/ngx_http_proxy_module.html
        proxy_set_header    X-Forwarded-For $remote_addr; # EP logs to show the actual remote IP
        proxy_set_header    X-Forwarded-Proto $scheme; # for EP to set secure cookie flag when https is used
        proxy_http_version  1.1; # recommended with keepalive connections

        # WebSocket proxying - from https://nginx.org/en/docs/http/websocket.html
        proxy_set_header  Upgrade $http_upgrade;
        proxy_set_header  Connection "upgrade";
        proxy_read_timeout 61s;
    '';
  };
  docker-containers."etherpad-lite" = {
    image = "makefoo/bgt-etherpad:2020-05-02.6";
    ports = [ "127.0.0.1:${toString port}:9001" ];
    volumes = [
      "/var/src/secrets/etherpad/apikey:/opt/etherpad-lite/APIKEY.txt"
      "etherpad_data:/opt/etherpad-lite/var" # persistent dirtydb
    ];
  # for postgres
  #DB_TYPE=postgres
  #DB_HOST=db.local
  #DB_PORT=4321
  #DB_NAME=etherpad
  #DB_USER=dbusername
  #DB_PASS=mypassword
    environment = {
      # ADMIN_PASSWORD = "auf jeden fall nicht das echte admin passwort";
      SUPPRESS_ERRORS_IN_PAD_TEXT = "true";
      TITLE = "Binärgewitter Etherpad";
      SKIN_NAME = "no-skin";
      DEFAULT_PAD_TEXT = builtins.replaceStrings ["\n"] ["\\n"] (builtins.readFile ./template.md);
      PAD_OPTIONS_USE_MONOSPACE_FONT = "true";
      PAD_OPTIONS_USER_NAME = "true";
      PAD_OPTIONS_USER_COLOR = "true";
      PAD_OPTIONS_CHAT_AND_USERS = "true";
      PAD_OPTIONS_LANG = "en-US";
    };
  };
}
