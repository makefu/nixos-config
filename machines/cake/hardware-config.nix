{ pkgs, lib, nixos-hardware, nixpkgs, ... }:
{
  imports = [ 
    nixos-hardware.nixosModules.raspberry-pi-4 
    #"${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_rpi4;
  #nixpkgs.pkgs = nixpkgs.legacyPackages.aarch64-linux;
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };
  console.enable = false;
  hardware = {
    raspberry-pi."4" = {
      apply-overlays-dtmerge.enable = true;
      audio.enable = true;  
      fkms-3d.enable = true; 
    };
    #deviceTree = {
    #  enable = true;
    #  filter = lib.mkForce "*rpi-4-*.dtb";
    #};
  };

  nixpkgs.localSystem.system = "aarch64-linux";

  environment.systemPackages = [ pkgs.libraspberrypi pkgs.raspberrypi-eeprom ];
}
