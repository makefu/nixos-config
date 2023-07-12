{config, pkgs, lib, ...}:

let
  dataDir = "/var/lib/zigbee2mqtt";
in
  {
  # symlink the zigbee controller

  services.zigbee2mqtt = {
    enable = true;
    inherit dataDir;
    settings = {
      permit_join = true;
      serial.port = "/dev/zigbee";
      homeassistant = true;
      frontend.port = 8521;
    };
  };

  state = [ "${dataDir}/devices.yaml" "${dataDir}/state.json" ];

  systemd.services.zigbee2mqtt = {
    # override automatic configuration.yaml deployment
    environment.ZIGBEE2MQTT_DATA = dataDir;
    after = [
      "home-assistant.service"
      "mosquitto.service"
      "network-online.target"
    ];
  };
}
