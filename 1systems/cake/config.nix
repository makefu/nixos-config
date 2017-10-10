{ config, lib, pkgs, ... }:
{
  imports = [
    <stockholm/makefu>
    <stockholm/makefu/2configs/tools/core.nix>
# configure your hw:
# <stockholm/makefu/2configs/save-diskspace.nix>
  ];
  users.extraUsers.root.openssh.authorizedKeys.keys = [
    config.krebs.users.tv.pubkey
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

  hardware.enableRedistributableFirmware = true;
  hardware.firmware = [
    (pkgs.stdenv.mkDerivation {
     name = "broadcom-rpi3-rest";
     src = pkgs.fetchurl {
     url = "https://raw.githubusercontent.com/RPi-Distro/firmware-nonfree/54bab3d/brcm80211/brcm/brcmfmac43430-sdio.txt";
     sha256 = "19bmdd7w0xzybfassn7x4rb30l70vynnw3c80nlapna2k57xwbw7";
     };
     phases = [ "installPhase" ];
     installPhase = ''
     mkdir -p $out/lib/firmware/brcm
     cp $src $out/lib/firmware/brcm/brcmfmac43430-sdio.txt
     '';
     })
  ];
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
