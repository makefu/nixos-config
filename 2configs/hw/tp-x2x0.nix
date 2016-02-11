{ config, lib, pkgs, ... }:

with lib;
{
  # TODO: put this somewhere else
  networking.wireless.enable = true;

  hardware.enableAllFirmware = true;
  nixpkgs.config.allowUnfree = true;

  hardware.cpu.intel.updateMicrocode = true;

  zramSwap.enable = true;
  zramSwap.numDevices = 2;

  hardware.trackpoint = {
    enable = true;
    sensitivity = 220;
    speed = 220;
    emulateWheel = true;
  };


  services.tlp.enable = true;
  services.tlp.extraConfig = ''
    START_CHARGE_THRESH_BAT0=80

    CPU_SCALING_GOVERNOR_ON_AC=performance
    CPU_SCALING_GOVERNOR_ON_BAT=ondemand
    CPU_MIN_PERF_ON_AC=0
    CPU_MAX_PERF_ON_AC=100
    CPU_MIN_PERF_ON_BAT=0
    CPU_MAX_PERF_ON_BAT=30
  '';
}
