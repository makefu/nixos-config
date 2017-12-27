{ config, pkgs, ... }:
{
  users.users.makefu.packages = with pkgs;[
    go-mtpfs
  ];

  boot.extraModulePackages = [ config.boot.kernelPackages.exfat-nofuse ];
}
