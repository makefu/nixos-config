{ config, lib, pkgs, ... }:

# ssd #
# sda:  bootloader grub2
# sda1: boot ext4 (label nixboot)
# sda2: cryptoluks ->
#       lvm:
#             /     (main-root)
#             /home (main-home)

with import <stockholm/lib>;
{

  imports = [
    ./sda-crypto-root.nix # configures crypto + boot
  ];
  fileSystems = {
    "/".device = lib.mkForce "/dev/mapper/main-root";
    "/home" = {
      device = "/dev/mapper/main-home";
      fsType = "ext4";
      options = [ "defaults" "discard" ];
    };
  };
}
