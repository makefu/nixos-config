{ lib, ... }:
let
  port = 19201;
in {
  #services.nginx.virtualHosts."euer.krebsco.de".serverAliases = [ "etherpad.euer.krebsco.de" ];
  services.nginx.virtualHosts."etherpad.euer.krebsco.de" = {
    # useACMEHost = "euer.krebsco.de";
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://localhost:${toString port}";
  };
  docker-containers."etherpad-lite" = {
    image = "makefoo/bgt-etherpad:2020-05-02.5";
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
