{ config, lib, pkgs, ... }:

with lib;
{

  imports = [ ./tp-x2x0.nix ];

  boot = {
    kernelModules = [ "tp_smapi" "msr" ];
    extraModulePackages = [ config.boot.kernelPackages.tp_smapi ];

  };
  services.thinkfan.enable = true;
}
