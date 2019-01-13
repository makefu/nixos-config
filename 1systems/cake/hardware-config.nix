{ pkgs, lib, ... }:
{
  # raspi3
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.kernelParams = ["cma=32M" "console=ttyS0,115200n8" "console=tty0" ];
  boot.tmpOnTmpfs = lib.mkForce false;
  hardware.enableRedistributableFirmware = true;

  ## wifi not working, will be fixed with https://github.com/NixOS/nixpkgs/pull/53747
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages = pkgs.linuxPackages;

  networking.wireless.enable = true;
  # File systems configuration for using the installer's partition layout
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/NIXOS_BOOT";
      fsType = "vfat";
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };
}
