{ pkgs, lib, ... }:
{
  boot.kernelParams = lib.mkForce ["console=ttyS2,1500000n8" "earlycon=uart8250,mmio32,0xff1a0000" "earlyprintk"];
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.loader.generic-extlinux-compatible.configurationLimit = 1;
  boot.loader.generationsDir.enable = lib.mkDefault false;
  boot.supportedFilesystems = lib.mkForce [ "vfat" ];

  boot.tmpOnTmpfs = lib.mkForce false;
  boot.cleanTmpDir = true;
  hardware.enableRedistributableFirmware = true;

  ## wifi not working, will be fixed with https://github.com/NixOS/nixpkgs/pull/53747
  boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.wireless.enable = true;
  # File systems configuration for using the installer's partition layout
  swapDevices = [ { device = "/var/swap"; size = 4096; } ];
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
