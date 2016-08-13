{config, ...}:
{
  networking.enableB43Firmware = true;
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
}

