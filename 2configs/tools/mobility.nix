{ config, pkgs, ... }:
{
  users.users.makefu.packages = with pkgs;[
    go-mtpfs
    mosh
    sshfs
    rclone
    exfat
    (pkgs.callPackage ./secrets.nix {})
  ];

  # boot.extraModulePackages = [ config.boot.kernelPackages.exfat-nofuse ];
}
