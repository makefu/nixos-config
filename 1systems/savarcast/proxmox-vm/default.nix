{ pkgs, lib, nixos-hardware, self, ... }:
# new zfs deployment
{
  imports = [
    ((import  ./disk-setup.nix ) { disks = [ "/dev/sda" "/dev/sdb"]; })
  ];

  swapDevices = [ ];
  boot.initrd.availableKernelModules = [ "nvme" "ehci_pci" "xhci_pci" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages;
  hardware.enableRedistributableFirmware = true;

}

