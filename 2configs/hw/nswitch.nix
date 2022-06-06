{ config, lib, pkgs, ... }:

{

  users.extraUsers.${config.krebs.build.user.name}.extraGroups = [ "dialout" ];

  # 1: USB
  # 2: RCM
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="3000", MODE="0660" ,GROUP="dialout"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0955", ATTRS{idProduct}=="7321", MODE="0660", GROUP="dialout"
  '';
}

