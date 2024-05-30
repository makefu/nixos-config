{config, pkgs, lib, ...}:

let
  dataDir = "/var/lib/zigbee2mqtt";
  port = 8521;
in
  {
  # symlink the zigbee controller

  networking.firewall.allowedTCPPorts = [ port ];

  services.zigbee2mqtt = {
    enable = true;
    inherit dataDir;
    settings = {
      permit_join = true;
      serial.port = "/dev/zigbee";
      homeassistant = true;
      frontend.port = port;
      frontend.host = "";
    };
  };

  state = [ "${dataDir}/devices.yaml" "${dataDir}/state.json" ];

  systemd.services.zigbee2mqtt = {
    # override automatic configuration.yaml deployment
    environment.ZIGBEE2MQTT_DATA = dataDir;
    after = [
      "home-assistant.service"
      "mosquitto.service"
      # "network-online.target"
    ];
  };
}
