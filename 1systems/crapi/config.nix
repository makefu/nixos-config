{ config, pkgs, lib, ... }:
{
  # :l <nixpkgs>
  # builtins.readDir (pkgs.fetchFromGitHub { owner = "nixos"; repo = "nixpkgs-channels"; rev = "6c064e6b"; sha256 = "1rqzh475xn43phagrr30lb0fd292c1s8as53irihsnd5wcksnbyd"; })
  imports = [
    <stockholm/makefu>
    <stockholm/makefu/2configs>
    <stockholm/makefu/2configs/tinc/retiolum.nix>
    <stockholm/makefu/2configs/save-diskspace.nix>

  ];
  krebs.build.host = config.krebs.hosts.crapi;
  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;

  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

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
    fi
  '';
  swapDevices = [ { device = "/swapfile"; size = 2048; } ];

  nix.package = lib.mkForce pkgs.nixStable;
  services.openssh.enable = true;

}
