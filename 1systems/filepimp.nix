# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../2configs/fs/single-partition-ext4.nix
      ../2configs/tinc-basic-retiolum.nix
      ../2configs/smart-monitor.nix
    ];
  krebs.build.host = config.krebs.hosts.filepimp;
  services.smartd.devices = [
    { device = "/dev/sda"; }
    { device = "/dev/sdb"; }
    { device = "/dev/sdc"; }
    { device = "/dev/sdd"; }
    { device = "/dev/sde"; }
  ];
  # AMD N54L
  boot = {
    loader.grub.device = "/dev/sde";

    initrd.availableKernelModules = [
      "ahci"
      "ohci_pci"
      "ehci_pci"
      "pata_atiixp"
      "usb_storage"
      "usbhid"
    ];

    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };
  hardware.enableAllFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;

  zramSwap.enable = true;
  zramSwap.numDevices = 2;
}
