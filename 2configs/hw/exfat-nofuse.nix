{ config, ... }:
{
  boot.extraModulePackages = [ config.boot.kernelPackages.exfat-nofuse ];
}
