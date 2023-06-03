{ config, pkgs, lib, ... }:
let
  confdir = "/var/lib/homeassistant-docker";
in {
  imports = [ 
    ./nginx.nix
    ./mqtt.nix
    ./signal-rest
    ./signal-rest/service.nix
  ];

  networking.firewall.allowedTCPPorts = [ 8123 ];
  state = [ "/var/lib/hass/known_devices.yaml" ];
  virtualisation.oci-containers.containers.hass = {
    image = "homeassistant/home-assistant:latest";
    environment = {
      TZ = "Europe/Berlin";
      UMASK = "007";
    };
    extraOptions = ["--net=host" ];
    volumes = [
      "${confdir}:/config"
      #"/data/music:/config/media"
    ];
  };
  systemd.tmpfiles.rules = [
    #"f ${confdir}/docker-run 0770 kiosk kiosk - -"
    "d ${confdir} 0770 kiosk kiosk - -"
  ];
}
