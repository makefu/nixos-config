{ config, lib, pkgs, ... }:

# ssd #
# sda:  bootloader grub2
# sda1: boot ext4 (label nixboot)
# sda2: cryptoluks -> lvm:
#       /     (main-root)
#       /home (main-home)

with lib;
{

  imports = [
    ./sda-crypto-root.nix
  ];

  fileSystems = {
    "/home" = {
      device = "/dev/mapper/main-home";
      fsType = "ext4";
      options="defaults,discard";
    };
  };
}
