{ config, pkgs, ... }:
{
  users.users.makefu.packages = with pkgs;[
    go-mtpfs
    mosh
    sshfs
    rclone
    exfat
    (pkgs.callPackage ./secrets.nix {})

    opensc pcsctools libu2f-host
  ];

  # boot.extraModulePackages = [ config.boot.kernelPackages.exfat-nofuse ];
}
