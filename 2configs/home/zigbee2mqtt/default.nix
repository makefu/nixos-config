{config, pkgs, lib, ...}:

let
  dataDir = "/var/lib/zigbee2mqtt";
  sec = import <secrets/zigbee2mqtt.nix>;
  internal-ip = "192.168.111.11";
  webport = 8521;
in
  {
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
    settings = {
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
      availability = {
        active.timeout = 10;
        passive.timeout = 1500;
      };
      frontend = {
        port = webport;
      };
      advanced = {
        log_level = "debug";
        log_output = [ "console" ];
        last_seen = "ISO_8601";
        elapsed = true;
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
    #serviceConfig.ExecStartPre = lib.mkForce "${pkgs.coreutils}/bin/true";
    after = [
      "home-assistant.service"
      "mosquitto.service"
      "network-online.target"
    ];
  };
}
