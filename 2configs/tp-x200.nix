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

  networking.wireless.enable = true;

  hardware.enableAllFirmware = true;
  nixpkgs.config.allowUnfree = true;

  hardware.trackpoint.enable = true;
  hardware.trackpoint.sensitivity = 255;
  hardware.trackpoint.speed = 255;
}
