{ pkgs, lib, ... }:
{
  #raspi1
  boot.kernelParams = ["cma=32M" "console=ttyS0,115200n8" "console=tty0" "console=ttyS1,115200n8" ];

  boot.loader.grub.enable = false;
  boot.loader.raspberryPi.enable = true;
  boot.loader.raspberryPi.version = 1;
  boot.loader.raspberryPi.uboot.enable = true;
  boot.loader.raspberryPi.uboot.configurationLimit = 1;
  boot.loader.generationsDir.enable = lib.mkDefault false;
  hardware.enableRedistributableFirmware = true;
  boot.cleanTmpDir = true;
  environment.systemPackages = [ pkgs.raspberrypi-tools ];
  boot.kernelPackages = pkgs.linuxPackages_rpi;

  nix.binaryCaches = [ "http://nixos-arm.dezgeg.me/channel" ];
  nix.binaryCachePublicKeys = [ "nixos-arm.dezgeg.me-1:xBaUKS3n17BZPKeyxL4JfbTqECsT+ysbDJz29kLFRW0=%" ];

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

  system.activationScripts.create-swap = ''
    if [ ! -e /swapfile ]; then
      fallocate -l 2G /swapfile
      mkswap /swapfile
      chmod 600 /swapfile
    fi
  '';
  swapDevices = [ { device = "/swapfile"; size = 4096; } ];
}
