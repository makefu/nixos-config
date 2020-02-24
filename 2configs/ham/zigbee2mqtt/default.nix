{config, pkgs, lib, ...}:

let
  pkg = pkgs.callPackage ./zigbee2mqtt.nix { };
in

{
  #users.users.z2m = {
  #  extraGroups = [ "dialout" ];
  #};

  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0451", ATTRS{idProduct}=="16a8", SYMLINK+="cc2531", MODE="0660", GROUP="dailout"
  '';
  #systemd.services.zigbee2mqtt = {
  #  wantedBy = ["multi-user.target" ];
  #  after = [ "network.target" ];
  #  description = "Run zigbee2mqtt as daemon";
  #  environment.ZIGBEE2MQTT_DATA = "/var/lib/zigbee2mqtt";
  #  serviceConfig = {
  #    WorkingDirectory = ''${pkg}/lib/node_modules/zigbee2mqtt'';
  #    ExecStart = ''${pkgs.nodejs-12_x}/bin/node index.js'';
  #    StandardOutput = "inherit";
  #    StandardError = "inherit";
  #    Restart = "always";
  #    User = "z2m";
  #    StateDirectory = "zigbee2mqtt";
  #    #DeviceAllow = "/dev/cc2531 rw";
  #  };
  #};
}
