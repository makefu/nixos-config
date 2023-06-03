{ lib,config, ... }:
# uses alsa instead of pulseaduio server
let
  profiles = "/var/lib/rhasspy";
in
{
  systemd.services.docker-rhasspy.after = [ "network-online.target" ];

  virtualisation.oci-containers.containers.rhasspy = {
    image = "rhasspy/rhasspy:latest";

    environment = {
      TZ = "Europe/Berlin";
      PULSE_SERVER = "tcp:${ config.krebs.build.host.name }:4713";
    };

    ports = [ 
      "12101:12101" 
    ];

    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "${profiles}:/profiles"
    ];

    cmd = [ "--user-profiles" "/profiles" "--profile" "de" ];
    extraOptions = [ 
      "--device=/dev/snd:/dev/snd"
      "--group-add=audio" 
    ];
  };
  systemd.tmpfiles.rules = [
    "d ${profiles} 0770 root root - -"
  ];

  # required to allow rhasspy to connect to pulse server
  # hardware.pulseaudio.enable = lib.mkForce false;
  networking.firewall.allowedTCPPorts = [ 4713 ];

}
