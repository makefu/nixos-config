{ config, lib, pkgs, ... }:

{

  users.extraUsers.${config.krebs.build.user.name}.extraGroups = [ "plugdev" ];

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="0955", MODE="0664", GROUP="plugdev"
  '';
}
