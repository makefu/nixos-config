{ config,...}:
let
  port = 14322;
  fqdn = "wiki.euer.krebsco.de";
in {
  services.nginx.virtualHosts."${fqdn}" = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://localhost:${toString port}";
  };
  sops.secrets.tiddlywiki-creds = { };
  systemd.services.tiddlywiki.serviceConfig.LoadCredential= "creds:${config.sops.secrets.tiddlywiki-creds}";
  services.tiddlywiki = {
    enable = true;
    listenOptions = {
      inherit port;
      credentials = "$CREDENTIALS_DIRECTORY/creds";
      readers = "(anon)";
    };
  };

}
