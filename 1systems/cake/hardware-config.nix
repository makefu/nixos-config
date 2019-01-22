{ pkgs, lib, ... }:
{
  # raspi3
  boot.kernelParams = ["cma=32M" "console=ttyS0,115200n8" "console=tty0" "console=ttyS1,115200n8" ];
  boot.loader.grub.enable = false;
  boot.loader.raspberryPi.enable = true;
  boot.loader.raspberryPi.version = 3;
  boot.loader.raspberryPi.uboot.enable = true;
  boot.loader.raspberryPi.uboot.configurationLimit = 3;
  boot.loader.raspberryPi.firmwareConfig = ''
    gpu_mem=32
    arm_freq=1350
    core_freq=500
    over_voltage=4
    disable_splash=1
    # bye bye warranty
    force_turbo=1
  '';
  boot.loader.generationsDir.enable = lib.mkDefault false;

  boot.tmpOnTmpfs = lib.mkForce false;
  boot.cleanTmpDir = true;
  hardware.enableRedistributableFirmware = true;

  ## wifi not working, will be fixed with https://github.com/NixOS/nixpkgs/pull/53747
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  environment.systemPackages = [ pkgs.raspberrypi-tools ];
  networking.wireless.enable = true;
  # File systems configuration for using the installer's partition layout
  swapDevices = [ { device = "/var/swap"; size = 2048; } ];
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
