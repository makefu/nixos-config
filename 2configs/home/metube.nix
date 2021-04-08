{ pkgs, lib, ...}:
# docker run -d -p 8081:8081 -v /path/to/downloads:/downloads --user 1001:1001 alexta69/metube
with import <stockholm/lib>;
let
  port = "2348";
  dl-dir = "/media/cryptX/youtube/music";
  uid = 20421;
  internal-ip = "192.168.111.11";
in
  {
  systemd.tmpfiles.rules = [
    "d ${dl-dir} metube nogroup - -"
  ];
  virtualisation.oci-containers.backend = "docker";

  services.nginx.virtualHosts."tube" = {
    serverAliases = [ "tube.lan" ];
    locations."/".proxyPass = "http://localhost:${port}";
  };

  virtualisation.oci-containers.containers.metube = {
    image = "alexta69/metube:latest";
    ports = [ "${port}:8081" ];
    volumes = [
      "${dl-dir}:/downloads"
    ];
    user = "metube";
  };
  users.users.metube.uid = uid;

  systemd.services.docker-metube.serviceConfig = {
    StandardOutput = lib.mkForce "journal";
    StandardError = lib.mkForce "journal";
  };
}
