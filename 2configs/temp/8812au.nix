{config, pkgs, ...}:
{
  #boot.extraModulePackages = [ pkgs.rtl8812au ];
  boot.extraModulePackages = [config.boot.kernelPackages.rtl8812au ];
  boot.kernelModules = [ "rtl8812au" ];
}
