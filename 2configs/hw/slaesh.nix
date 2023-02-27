{ config, lib, pkgs, ... }:

{

  users.users.${config.krebs.build.user.name}.extraGroups = [ "dialout" ];
  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", SYMLINK+="zigbee", MODE="0660", GROUP="dailout"
  '';
}
