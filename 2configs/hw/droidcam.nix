{ pkgs, config, ... }: 
{
  boot.extraModprobeConfig = "options v4l2loopback_dc width=640 height=480";
  boot.extraModulePackages = [
    (pkgs.callPackage  ../../5pkgs/v4l2loopback-dc { kernel = config.boot.kernelPackages.kernel; })
  ];
}
