{config, pkgs, lib, ...}:

let
  dataDir = "/var/lib/zigbee2mqtt";
in
  {
  # symlink the zigbee controller
  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0451", ATTRS{idProduct}=="16a8", SYMLINK+="cc2531", MODE="0660", GROUP="dialout"
  '';

  services.zigbee2mqtt = {
    enable = true;
    inherit dataDir;
    settings = {
      permit_join = true;
      serial.port = "/dev/cc2531";
      homeassistant = true;
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
