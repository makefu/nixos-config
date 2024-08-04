{ config, pkgs, lib, ...}:
let
  port = "2348";
  music-dir = "/media/silent/music/youtube";
  dl-dir = "/media/cryptX/youtube";
  uid = 20421;
  internal-ip = "192.168.111.11";
in
  {

  services.nginx.virtualHosts."tube" = {
    serverAliases = [ "tube.lan" "mtube.lan" ];
    locations."/" = {
      proxyPass = "http://localhost:${port}";
      proxyWebsockets = true;
    };
  };

  virtualisation.oci-containers.containers.metube = {
    image = "alexta69/metube:latest";
    ports = [ "${port}:8081" ];
    volumes = [
      "${music-dir}:/music"
      "${dl-dir}:/downloads"
    ];
    environment = {
      UID = toString config.users.users.download.uid;
      GID = toString config.users.groups.download.gid;
      DOWNLOAD_DIR = "/downloads";
      AUDIO_DOWNLOAD_DIR = "/music";
      #PUBLIC_HOST_URL = "tube.lan";
      #PUBLIC_HOST_AUDIO_URL = "mtube.lan";
    };
    #user = "metube";
  };
}
