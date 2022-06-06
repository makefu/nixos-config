{ pkgs, ... }:
let
  port = 8812;
in {
  services.vaultwarden = {
    enable = true;
    dbBackend = "postgresql";
    config.signups_allowed = false;
    config.rocketPort = port;
    config.domain = "https://bw.euer.krebsco.de";
    #config.databaseUrl = "postgresql://bitwardenuser:${dbPassword}@localhost/bitwarden";
    config.databaseUrl = "postgresql:///bitwarden";
    config.websocket_enabled = true;
  };

  systemd.services.vaultwarden.after = [ "postgresql.service" ];

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "bitwarden" ];
    ensureUsers = [
      { name = "bitwarden_rs"; ensurePermissions."DATABASE bitwarden" = "ALL PRIVILEGES"; } 
      { name = "vaultwarden"; ensurePermissions."DATABASE bitwarden" = "ALL PRIVILEGES"; } 
    ];
  };
  services.postgresqlBackup = {
    enable = true;
    databases = [ "bitwarden" "vaultwarden" ];
  };


  services.nginx.virtualHosts."bw.euer.krebsco.de" ={
    forceSSL = true;
    enableACME = true;

    locations."/" = {
      proxyPass = "http://localhost:8812";
      proxyWebsockets = true;
    };
    locations."/notifications/hub" = {
      proxyPass = "http://localhost:3012";
      proxyWebsockets = true;
    };
    locations."/notifications/hub/negotiate" = {
      proxyPass = "http://localhost:8812";
      proxyWebsockets = true;
    };
  };
}
