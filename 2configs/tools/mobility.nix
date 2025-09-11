{ config, pkgs, ... }:
{
    state = [
        "/home/makefu/.config/rclone/rclone.conf"
  ];
  users.users.makefu.packages = with pkgs;[
    go-mtpfs
    mosh
    sshfs
    rclone

    # (pkgs.callPackage ./secrets.nix {})

    opensc pcsctools libu2f-host
  ];
  boot.supportedFilesystems = [ "exfat" ];
}
