{ lib, config, ... }:
let
  web-port = 19455;
  hostn = "ntfy.euer.krebsco.de";
  internal-ip = config.krebs.build.host.nets.retiolum.ip4.addr;
in 
{
  services.ntfy-sh = {
    enable = true;
    settings = {
      listen-http = "127.0.0.1:${toString web-port}";
      auth-file = "/var/lib/ntfy-sh/user.db";
      auth-default-access = "deny-all";
      behind-proxy = true;
      attachment-cache-dir = "/media/cloud/ntfy-sh/attachments";
      attachment-file-size-limit = "500m";
      attachment-total-size-limit = "100g";
      base-url = "https://ntfy.euer.krebsco.de";
      attachment-expiry-duration = "48h";
    };
  };

  systemd.services.ntfy-sh.serviceConfig = {
    StateDirectory = "ntfy-sh";
    SupplementaryGroups = [ "download" ];
  };
  
  services.nginx = {
    enable = lib.mkDefault true;
    virtualHosts."${hostn}" = {
      forceSSL = true;
      enableACME = true;

      locations."/" = {
        proxyPass  = "http://localhost:${toString web-port}/";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };
  };
}
