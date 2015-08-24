{ config, lib, pkgs, ... }:

with lib;
{
  # TODO: put this somewhere else
  networking.wireless.enable = true;

  hardware.enableAllFirmware = true;
  nixpkgs.config.allowUnfree = true;

  zramSwap.enable = true;
  zramSwap.numDevices = 2;

  hardware.trackpoint.enable = true;
  hardware.trackpoint.sensitivity = 220;
  hardware.trackpoint.speed = 220;

  services.tlp.enable = true;
  services.tlp.extraConfig = ''
  START_CHARGE_THRESH_BAT0=80
  '';
}
