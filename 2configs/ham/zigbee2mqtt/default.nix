{config, pkgs, lib, ...}:


{
  # symlink the zigbee controller
  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0451", ATTRS{idProduct}=="16a8", SYMLINK+="cc2531", MODE="0660", GROUP="dailout"
  '';

  system.activationScripts.installZigbee = ''
    install -d /var/lib/zigbee2mqtt
  '';

  docker-containers.zigbee2mqtt = {
    image = "koenkk/zigbee2mqtt";
    extraDockerOptions = [ "--device=/dev/cc2531:/dev/cc2531" ];
    volumes = ["/var/lib/zigbee2mqtt:/app/data"];
  };
  state = [ "/var/lib/zigbee2mqtt/configuration.yaml" "/var/lib/zigbee2mqtt/state.json" ];
}
