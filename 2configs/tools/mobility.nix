{ config, pkgs, ... }:
{
  users.users.makefu.packages = with pkgs;[
    go-mtpfs
    mosh
  ];

  # boot.extraModulePackages = [ config.boot.kernelPackages.exfat-nofuse ];
}
