{ config, pkgs, lib, ... }:
let
  kodi-host = "192.168.8.11";
  confdir = "/var/lib/homeassistant-docker";
in {
  imports = [
    ./ota.nix
    ./comic-updater.nix
    # ./puppy-proxy.nix

    ./zigbee2mqtt
    #./rhasspy.nix
    ./esphome.nix
    ./jellyfin.nix
    ./ha-ara-menu.nix
    ./inventory4ce.nix

    # hass config
    ## complex configs
    # ./multi/daily-standup.nix
    #./multi/aramark.nix
    #./multi/matrix.nix
    #./multi/frosch.nix
    #./multi/mittagessen.nix
    #./multi/10h_timers.nix

    #./switch/tasmota_switch.nix
    #./switch/rfbridge.nix

    #./light/statuslight.nix
    #./light/buzzer.nix

    #./script/multi_blink.nix

    #./binary_sensor/buttons.nix
    #./binary_sensor/motion.nix

    ## ./sensor/pollen.nix requires dwd_pollen
    #./sensor/espeasy.nix
    #./sensor/airquality.nix
    #./sensor/outside.nix
    #./sensor/tasmota_firmware.nix

    #./camera/verkehrskamera.nix
    #./camera/comic.nix
    #./camera/stuttgart.nix
    #./automation/bureau-shutdown.nix
    #./automation/nachtlicht.nix
    #./automation/schlechteluft.nix
    #./automation/philosophische-tuer.nix
    #./automation/hass-restart.nix
    #./device_tracker/openwrt.nix
    #./person/team.nix
  ];

  networking.firewall.allowedTCPPorts = [ 8123 ];
  state = [ "/var/lib/hass/known_devices.yaml" ];
  virtualisation.oci-containers.containers.hass = {
    image = "homeassistant/home-assistant:latest";
    #user = "${toString config.users.users.kiosk.uid}:${toString config.users.groups.kiosk.gid}";
    #user = "${toString config.users.users.kiosk.uid}:root";
    environment = {
      TZ = "Europe/Berlin";
      PUID = toString config.users.users.kiosk.uid;
      PGID = toString config.users.groups.kiosk.gid;
      UMASK = "007";
    };
    extraOptions = ["--net=host" ];
    volumes = [
      "${confdir}:/config"
      "/data/music:/config/media"
      "/run/dbus:/run/dbus:ro"
      #"${confdir}/docker-run:/etc/services.d/home-assistant/run:"
    ];
  };
  systemd.tmpfiles.rules = [
    #"f ${confdir}/docker-run 0770 kiosk kiosk - -"
    "d ${confdir} 0770 kiosk kiosk - -"
  ];
}
