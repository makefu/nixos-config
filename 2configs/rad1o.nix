{ config, lib, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    gnuradio-full
    gnuradio-osmosdr
    gqrx
    ];

  users.extraUsers.${config.krebs.build.user.name}.extraGroups = [ "dialout" ];

  services.udev.extraRules = ''
    ATTR{idVendor}=="1d50", ATTR{idProduct}=="604b", SYMLINK+="hackrf-jawbreaker-%k", MODE="0666", GROUP="dialout"
    ATTR{idVendor}=="1d50", ATTR{idProduct}=="6089", SYMLINK+="hackrf-one-%k", MODE="0666", GROUP="dialout"
    ATTR{idVendor}=="1d50", ATTR{idProduct}=="cc15", SYMLINK+="rad1o-%k", MODE="0666", GROUP="dialout"
    ATTR{idVendor}=="1fc9", ATTR{idProduct}=="000c", SYMLINK+="nxp-dfu-%k", MODE="0666", GROUP="dialout"
  '';
}
