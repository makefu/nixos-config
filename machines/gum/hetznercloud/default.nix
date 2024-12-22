{ config, lib, pkgs, modulesPath, ... }:
{

  imports =
    [ 
      ./network.nix
      (modulesPath + "/profiles/qemu-guest.nix")
      ./single-disk-ext4.nix

    ];
  zramSwap.enable = true;  
  zramSwap.memoryPercent = 75;
  # Disk
  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "sd_mod" "sr_mod" ];
  boot.uki.tries = 3;
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  boot.kernelParams = [
    "boot.shell_on_fail"
    "panic=30" "boot.panic_on_fail" # reboot the machine upon fatal boot issues
  ];
}
