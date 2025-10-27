{ config, pkgs, lib, ...}:
let
  port = "2349";
  db-dir = "/media/silent/db/yamtrack";
  internal-ip = "192.168.111.11";
in
  {

  services.nginx.virtualHosts."track" = {
    serverAliases = [ "tube.lan" "mtube.lan" ];
    locations."/" = {
      proxyPass = "http://localhost:${port}";
      proxyWebsockets = true;
    };
  };
  sops.secrets.yamtrack = {};
  virtualisation.oci-containers.containers.yamtrack = {
    image = "ghcr.io/fuzzygrim/yamtrack:latest";
    ports = [ "${port}:8000" ];
    volumes = [
      "${db-dir}:/yamtrack/db"
  ];
     extraOptions = [ # allow access to local redis
    "--network=host"
];
  environmentFiles = [
      config.sops.secrets.yamtrack.path # SECRET=
  ];
    environment = {
        TZ=config.time.timeZone;
        REDIS_URL = "redis://localhost:6379";
      #PUBLIC_HOST_URL = "tube.lan";
      #PUBLIC_HOST_AUDIO_URL = "mtube.lan";
    };
    #user = "metube";
  };
services.redis.enable = true;
}
