{ pkgs, lib, ... }:
{
  imports = [ 
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ./wifi.nix
    ./sound.nix
  ];
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "sd_mod" ];
  boot.kernelModules = [ "kvm-amd" ];
  disko.devices = import ./disk.nix;
  
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  boot.kernelParams = [ "net.ifnames=0" ];
  networking.hostId = "0123AABB";

}
