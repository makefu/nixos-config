{ config, lib, pkgs, ... }:

with lib;
{

  imports = [ ./tp-x2x0.nix ];

  boot.kernelModules = [ "kvm-intel" ];
  services.xserver.displayManager.sessionCommands =''
  xinput set-int-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation" 8 1
  xinput set-int-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Button" 8 2
  xinput set-int-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Timeout" 8 200
  xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Axes" 6 7 4 5
  '';

}
