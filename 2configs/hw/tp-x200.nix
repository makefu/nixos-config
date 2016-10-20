{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
{

  imports = [ ./tp-x2x0.nix ];

  boot = {
    kernelModules = [ "tp_smapi" "msr" ];
    extraModulePackages = [ config.boot.kernelPackages.tp_smapi ];

  };
  services.thinkfan.enable = true;

  # only works on tp-x200 , not x220
  services.xserver.displayManager.sessionCommands = ''
    xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation" 1
    xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Button" 2
    xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Timeout" 200
  '';
}
