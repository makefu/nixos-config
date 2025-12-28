{ config, lib, ... }:
let
  port = 19201;
  realport = 9001;
in {
  #services.nginx.virtualHosts."euer.krebsco.de".serverAliases = [ "etherpad.euer.krebsco.de" ];
  #virtualisation.oci-containers.backend = "docker";
  #virtualisation.podman = {
  #  defaultNetwork.settings.dns_enabled = true;
  #  dockerCompat = true;
  #  enable = true;
  #};

  # sops.secrets.etherpad_htpasswd.owner = "nginx";

  services.nginx.virtualHosts."etherpad.euer.krebsco.de" = {
    # useACMEHost = "euer.krebsco.de";
    extraConfig = ''
      ssl_session_timeout  30m;
    '';
    enableACME = true;
    forceSSL = true;
    locations."/" = {
        proxyPass = "http://127.0.0.1:${toString realport}";
        #basicAuthFile = config.sops.secrets.etherpad_htpasswd.path;
        extraConfig = ''

            proxy_buffering    off; # be careful, this line doesn't override any proxy_buffering on set in a conf.d/file.conf
            proxy_set_header   Host $host;
            proxy_pass_header  Server;

            # Note you might want to pass these headers etc too.
            proxy_set_header    X-Real-IP $remote_addr; # https://nginx.org/en/docs/http/ngx_http_proxy_module.html
            proxy_set_header    X-Forwarded-For $remote_addr; # EP logs to show the actual remote IP
            proxy_set_header    X-Forwarded-Proto $scheme; # for EP to set secure cookie flag when https is used
            proxy_http_version  1.1; # recommended with keepalive connections

            proxy_set_header  Upgrade $http_upgrade;
            proxy_set_header  Connection "upgrade";
            proxy_read_timeout 1799s;
        '';
    };
    # from https://github.com/ether/etherpad-lite/wiki/How-to-put-Etherpad-Lite-behind-a-reverse-Proxy
  };
  sops.secrets.etherpad-apikey.mode = "0440";
  sops.secrets.etherpad-config.mode = "0440";
  state = [ "/var/lib/containers/storage/volumes/etherpad_data/_data/rusty.db" ];
  virtualisation.oci-containers.containers."etherpad-lite" = {
    #image = "makefoo/bgt-etherpad:2021-04-16.3"; # --build-arg ETHERPAD_PLUGINS="ep_markdown"
    #image = "etherpad/etherpad:1.9.4";
    #image = "etherpad/etherpad:1.8.14";
    image = "etherpad/etherpad:2.5.3";
    extraOptions = [ "--network=host"];
    ports = [ "127.0.0.1:${toString port}:${toString realport}" ];
    volumes = [
      "${ config.sops.secrets.etherpad-apikey.path }:/opt/etherpad-lite/APIKEY.txt"
      "${ config.sops.secrets.etherpad-config.path }:/opt/etherpad-lite/settings.json:ro"
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
      LOGLEVEL = "DEBUG";
      SUPPRESS_ERRORS_IN_PAD_TEXT = "true";
      # IP = "::";
      TRUST_PROXY =  "true";
      SHOW_SETTINGS_IN_ADMIN_PAGE = "true";
      TITLE = "Binärgewitter Etherpad";
      SKIN_NAME = "no-skin";
      DEFAULT_PAD_TEXT = builtins.readFile ./template.md;
      PAD_OPTIONS_USE_MONOSPACE_FONT = "true";
      PAD_OPTIONS_USER_NAME = "true";
      PAD_OPTIONS_USER_COLOR = "true";
      PAD_OPTIONS_CHAT_AND_USERS = "true";
      PAD_OPTIONS_LANG = "en-US";
      ETHERPAD_PLUGINS = "ep_openid_connect ep_markdown";
    };
  };
}
