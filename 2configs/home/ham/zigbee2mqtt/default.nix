{config, pkgs, lib, ...}:

let
  dataDir = "/var/lib/zigbee2mqtt";
  sec = import <secrets/zigbee2mqtt.nix>;
in
  {
  # symlink the zigbee controller
  #services.udev.extraRules = ''
  #  SUBSYSTEM=="tty", ATTRS{idVendor}=="0451", ATTRS{idProduct}=="16a8", SYMLINK+="cc2531", MODE="0660", GROUP="dialout"
  #'';
  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", SYMLINK+="cc2531", MODE="0660", GROUP="dialout"
  '';

  services.zigbee2mqtt = {
    enable = true;
    inherit dataDir;
    config = {
      permit_join = true;
      serial.port = "/dev/cc2531";
      homeassistant = true;
      mqtt = {
        server = "mqtt://omo.lan:1883";
        base_topic = "/ham/zigbee";
        user = sec.mqtt.username;
        password = sec.mqtt.password;
        include_device_information = true;
        client_id = "zigbee2mqtt";
      };
      advanced = {
        log_level = "debug";
        log_output = [ "console" ];
        last_seen = "ISO_8601";
        elapsed = true;
        reporting = true; # TODO test if it is better with groups
        pan_id = 6755;
        inherit (sec.zigbee) network_key;
      };
      map_options.graphviz.colors = {
        fill = {
          enddevice =  "#fff8ce" ;
          coordinator = "#e04e5d";
          router = "#4ea3e0";
        };
        font = {
          coordinator= "#ffffff";
          router = "#ffffff";
          enddevice = "#000000";
        };
        line = {
          active = "#009900";
          inactive = "#994444";
        };
      };
    };
  };

  state = [ "${dataDir}/devices.yaml" "${dataDir}/state.json" ];

  systemd.services.zigbee2mqtt = {
    # override automatic configuration.yaml deployment
    environment.ZIGBEE2MQTT_DATA = dataDir;
    #serviceConfig.ExecStartPre = lib.mkForce "${pkgs.coreutils}/bin/true";
    after = [
      "home-assistant.service"
      "mosquitto.service"
      "network-online.target"
    ];
  };
}
