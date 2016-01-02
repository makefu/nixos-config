# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../2configs/fs/single-partition-ext4.nix
      ../2configs/tinc-basic-retiolum.nix
    ];
  krebs.build.host = config.krebs.hosts.filepimp;

  # AMD N54L
  boot = {
    loader.grub.device = "/dev/sda";

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

  networking.firewall.allowPing = true;
}
