{ config, lib, pkgs, ... }:

# ssd #
# sda:  bootloader grub2
# sda1: boot ext4 (label nixboot)
# sda2: cryptoluks -> lvm:
#       /     (main-root)
#       /home (main-home)

with lib;
{
  boot = {
    loader.grub.enable =true;
    loader.grub.version =2;
    loader.grub.device = "/dev/sda";

    initrd.luks.devices = [ { name = "main"; device = "/dev/sda2"; allowDiscards=true; }];
    initrd.luks.cryptoModules = ["aes" "sha512" "sha1" "xts" ];
    initrd.availableKernelModules = ["xhci_hcd" "ehci_pci" "ahci" "usb_storage" ];
  };
  fileSystems = {
    "/" = {
      device = "/dev/mapper/main-root";
      fsType = "ext4";
      options="defaults,discard";
    };
    # TODO: just import sda-crypto-root, add this device
    "/home" = {
      device = "/dev/mapper/main-home";
      fsType = "ext4";
      options="defaults,discard";
    };
    "/boot" = {
      device = "/dev/disk/by-label/nixboot";
      fsType = "ext4";
      options="defaults,discard";
    };
  };
}
