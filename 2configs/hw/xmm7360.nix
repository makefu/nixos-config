{ pkgs, config, ... }:
let
  pkg = (pkgs.callPackage ../../5pkgs/xmm7360 { kernel = config.boot.kernelPackages.kernel; });
in
{
  boot.extraModulePackages = [
    pkg
  ];
  boot.initrd.availableKernelModules = [ "xmm7360" ];
  users.users.makefu.packages = [ pkg ];
}
