{ config, lib, pkgs, ... }:

with lib;
{
  #services.xserver = {
  #  videoDriver = "intel";
  #};

  boot = {
    kernelModules = [ "tp_smapi" "msr" ];
    extraModulePackages = [ config.boot.kernelPackages.tp_smapi ];

  };

  #networking.wireless.enable = true;

  hardware.enableAllFirmware = true;
  nixpkgs.config.allowUnfree = true;

  zramSwap.enable = true;
  zramSwap.numDevices = 2;

  hardware.trackpoint.enable = true;
  hardware.trackpoint.sensitivity = 255;
  hardware.trackpoint.speed = 255;
  services.xserver.displayManager.sessionCommands = ''
    xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation" 1
    xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Button" 2
    xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Timeout" 200
  '';

  services.thinkfan.enable = true;
  services.tlp.enable = true;
  services.tlp.extraConfig = ''
  START_CHARGE_THRESH_BAT0=80
  '';
}
