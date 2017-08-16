{ config, lib, pkgs, ... }:

# sda:  bootloader grub2
# sda1: boot ext4 (label nixboot) - must be unlocked on boot if required:
  # boot.initrd.luks.devices = [ { name = "luksroot"; device = "/dev/sda2"; allowDiscards=true; }];
# sda2: cryptoluks -> ext4

# fdisk /dev/sda
  # boot 500M
  # rest rest
# cryptsetup luksFormat /dev/sda2
#
with import <stockholm/lib>;
{
  boot = {
    loader.grub.enable = true;
    loader.grub.version = 2;
    loader.grub.device = lib.mkDefault "/dev/sda";

    initrd.luks.cryptoModules = ["aes" "sha512" "sha1" "xts" ];
    initrd.availableKernelModules = ["xhci_hcd" "ehci_pci" "ahci" "usb_storage" ];
  };
  fileSystems = {
    "/" = {
      device = "/dev/mapper/luksroot";
      fsType = "ext4";
      options = [ "defaults" "discard" ];
    };
    "/boot" = {
      device = "/dev/disk/by-label/nixboot";
      fsType = "ext4";
      options = [ "defaults" "discard" ];
    };
  };
}
