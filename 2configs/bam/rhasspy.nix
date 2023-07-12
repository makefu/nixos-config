{ config, ... }:
let
  profiles = "/var/lib/rhasspy";
  kiosk_id = toString config.users.users.kiosk.uid;
in
{
  virtualisation.oci-containers.containers.rhasspy = {
    image = "rhasspy/rhasspy:latest";

    environment = {
      TZ = "Europe/Berlin";
      #PULSE_SERVER = "unix:/run/user/0/pulse/native";
      PULSE_SERVER = "tcp:${ config.krebs.build.host.name }:4713";

    };

    ports = [ 
      "12101:12101" 
      # "12183:12183"
    ];
    #user = kiosk_id;

    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "${profiles}:/profiles"
      # TODO pulseaudio
      #"/run/user/${kiosk_id}/pulse/native:/run/user/0/pulse/native"
      #"${config.users.users.kiosk.home}/.config/pulse/cookie:/root/.config/pulse/cookie:ro"
    ];

    cmd = [ "--user-profiles" "/profiles" "--profile" "de" ];
    extraOptions = [
      "--device=/dev/snd:/dev/snd" "--group-add=audio"
      "--net=host"
    ];
  };
  systemd.tmpfiles.rules = [
    "d ${profiles} 0770 root root - -"
  ];
  systemd.services.docker-rhasspy.after = [ "desktop-manager.service" ];
}
