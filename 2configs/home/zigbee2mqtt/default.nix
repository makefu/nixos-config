{config, pkgs, lib, ...}:

let
  dataDir = "/var/lib/zigbee2mqtt";
  internal-ip = "192.168.111.11";
  webport = 8521;
in
{
  sops.secrets."omo-zigbee2mqtt" = {
    owner = "zigbee2mqtt";
    path = "/var/lib/zigbee2mqtt/configuration.yaml";
  };
  # symlink the zigbee controller
  #services.udev.extraRules = ''
  #  SUBSYSTEM=="tty", ATTRS{idVendor}=="0451", ATTRS{idProduct}=="16a8", SYMLINK+="cc2531", MODE="0660", GROUP="dialout"
  #'';

  # /dev/serial/by-id/usb-Silicon_Labs_slae.sh_cc2652rb_stick_-_slaesh_s_iot_stuff_00_12_4B_00_21_CC_45_BD-if00-port0
  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", SYMLINK+="cc2531", MODE="0660", GROUP="dialout"
  '';

  services.zigbee2mqtt = {
    enable = true;
    inherit dataDir;
    # sets DeviceAllow in systemd service
    settings.serial.port = "/dev/cc2531";
  };

  services.nginx.recommendedProxySettings = true;
  services.nginx.virtualHosts."zigbee" = {
    serverAliases = [ "zigbee.lan" ];
    locations."/".proxyPass = "http://localhost:${toString webport}";
    locations."/api".proxyPass = "http://localhost:${toString webport}";
    locations."/api".proxyWebsockets = true;
    extraConfig = ''
      if ( $server_addr != "${internal-ip}" ) {
        return 403;
      }
    '';
  };

  state = [ "${dataDir}/devices.yaml" "${dataDir}/state.json" ];

  systemd.services.zigbee2mqtt = {
    # override automatic configuration.yaml deployment
    environment.ZIGBEE2MQTT_DATA = dataDir;
    serviceConfig.ExecStartPre = lib.mkForce "${pkgs.coreutils}/bin/true";
    after = [
      "home-assistant.service"
      "mosquitto.service"
      # "network-online.target"
    ];
  };
}
