let
  stateDir = "/media/silent/db/komga"
in {
  services.komga ={
    settings.server.port = 52121;
    inherit stateDir;
  };

  systemd.tmpfiles.rules = [
    "d ${stateDir} 0750 ${config.services.komga.user} ${config.services.komga.group} - -"
  ];
}
