{ config, lib, pkgs, ... }:

{

  users.users.makefu.packages = with pkgs; [
    lirc
  ];

  users.extraUsers.makefu.extraGroups = [ "dialout" ];

  services.udev.extraRules = ''
    SUBSYSTEMS=="usb", ATTRS{idProduct}=="fd08", ATTRS{idVendor}=="04d8", SYMLINK+="irtoy", MODE="0666", GROUP="dialout"
  '';
}

