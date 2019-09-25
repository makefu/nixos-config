{config, lib, pkgs, ...}:
let
  web_port = 9011;
  statedir = "/var/lib/shiori";
in {
  state = [ statedir ];
  systemd.services.shiori = {
    description = "Shiori Server";
    after = [ "network-online.target" ];
    environment = {
      SHIORI_DIR = statedir;
    };
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      DynamicUser = true;
      StateDirectory = "shiori";
      ExecStart = "${pkgs.shiori}/bin/shiori serve -a 127.0.0.1 -p ${toString web_port}";
      PrivateTmp = true;
    };
  };
  services.nginx.virtualHosts."bookmark.euer.krebsco.de" = {
    forceSSL = true;
    enableACME = true;

    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString web_port}/";
    };
  };
}
