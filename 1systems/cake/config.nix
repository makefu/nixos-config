{ config, lib, pkgs, ... }:
{
  imports = [
    <stockholm/makefu>
    <stockholm/makefu/2configs/tools/core.nix>
# configure your hw:
# <stockholm/makefu/2configs/save-diskspace.nix>
  ];
  krebs = {
    enable = true;
    tinc.retiolum.enable = true;
    build.host = config.krebs.hosts.cake;
  };
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = ["cma=32M" "console=ttyS0,115200n8" "console=tty0" ];

  programs.info.enable = false;
  programs.man.enable = false;
  services.nixosManual.enable = false;
  boot.tmpOnTmpfs = lib.mkForce false;

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
