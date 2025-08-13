{ config, ...  }:
let
  stateDir = "/media/silent/db/komga";
  port = 52121;
in {
  services.komga ={
    enable = true;
    settings.server.port = port;
    inherit stateDir;
    openFirewall = true;
    group = "download";
  };
  networking.firewall.allowedTCPPorts = [ port ];
  systemd.tmpfiles.rules = [
    "d ${stateDir} 0750 ${config.services.komga.user} ${config.services.komga.group} - -"
  ];
}
