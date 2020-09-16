{ config, lib, pkgs, ... }:

{

  users.users.makefu.extraGroups = [ "plugdev" ];
  users.groups.plugdev = {};
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="0955", MODE="0664", GROUP="plugdev"
    SUBSYSTEM=="usb", ATTR{idVendor}=="16c0", ATTR{idProduct}=="27e2", SYMLINK+="switch-%k", MODE="0664", GROUP="plugdev"
    SUBSYSTEM=="usb", ATTR{idVendor}=="057e", ATTR{idProduct}=="3000", SYMLINK+="switch-%k", MODE="0664", GROUP="plugdev"
  '';
}
