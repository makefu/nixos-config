{ config, lib, pkgs, ... }:

# ssd #
# sda:  bootloader grub2
# sda1: boot ext4 (label nixboot)
# sda2: cryptoluks ->
#       lvm:
#             /     (main-root)
#             /home (main-home)

# clean the boot sector:
# dd if=/dev/zero of=/dev/sda count=2048
# Installation Instruction on ISO:
# fdisk /dev/sda
  # boot 500M
  # rest rest
# cryptsetup luksFormat /dev/sda2
# mkfs.ext4 -L nixboot /dev/sda1
# cryptsetup luksOpen /dev/sda2 cryptoluks
# pvcreate /dev/mapper/cryptoluks
# vgcreate main /dev/mapper/cryptoluks
# lvcreate -L 200Gib main -n root
# lvcreate -L 800Gib main -n home
# mkfs.ext4 /dev/main/root
# mkfs.ext4 /dev/main/home
# mount /dev/mapper/main-root /mnt
# mkdir -p /mnt/{boot,home,var/src} /var/src
# mount /dev/sda1 /mnt/boot
# mount /dev/mapper/main-home /mnt/home
# touch /mnt/var/src/.populate
# mount -o bind /mnt/var/src /var/src
# nix-channel --add  https://nixos.org/channels/nixos-19.03 nixpkgs && # nix-channel --update
# nix-env -iA nixpkgs.gitMinimal
# (on deploy-host) $(nix-build ~/stockholm/makefu/krops.nix --no-out-link --argstr name x  --argstr target 10.42.22.91 -A deploy --show-trace)
# NIXOS_CONFIG=/var/src/nixos-config nixos-install -I /var/src --no-root-passwd --no-channel-copy
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
