{ config, lib, pkgs, ... }:

# vda1 ext4 (label nixos) -> only root partition
{
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "ext4";
  };

  hardware.enableRedistributableFirmware = true;
  nixpkgs.config.allowUnfree = true;
}
