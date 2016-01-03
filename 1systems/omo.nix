# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      # TODO: unlock home partition via ssh
      ../2configs/fs/single-partition-ext4.nix
      ../2configs/tinc-basic-retiolum.nix
      ../2configs/zsh-user.nix
      ../2configs/exim-retiolum.nix
      ../2configs/smart-monitor.nix
    ];
  krebs.build.host = config.krebs.hosts.omo;
  services.smartd.devices = [
    { device = "/dev/sda"; }
    { device = "/dev/sdb"; }
    { device = "/dev/sdc"; }
    { device = "/dev/sdd"; }
    { device = "/dev/sde"; }
  ];

  # AMD E350
  fileSystems."/home" = {
    device = "/dev/mapper/home";
    fsType = "ext4";
  };
  powerManagement.powerUpCommands = ''
  for i in a b c d e f g h i;do
    ${pkgs.hdparm}/sbin/hdparm -S 100 /dev/sd$i
    ${pkgs.hdparm}/sbin/hdparm -B 127 /dev/sd$i
    ${pkgs.hdparm}/sbin/hdparm -y /dev/sd$i
  '';
  boot = {
    initrd.luks = {
      devices = [
        { name = "home";
          device = "/dev/disk/by-uuid/85bff22e-dcbb-4246-b030-faf6c1782995";
          keyFileSize = 4096;
          keyFile = "/dev/disk/by-id/usb-Verbatim_STORE_N_GO_070B3CEE0B223954-0:0"; }
      ];
    };
    loader.grub.device = "/dev/disk/by-id/ata-INTEL_SSDSA2M080G2GC_CVPO003402PB080BGN";

    initrd.availableKernelModules = [
      "ahci"
      "ohci_pci"
      "ehci_pci"
      "pata_atiixp"
      "firewire_ohci"
      "usb_storage"
      "usbhid"
    ];

    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };

  networking.firewall.allowedUDPPorts = [ 655 ];
  hardware.enableAllFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;

  #zramSwap.enable = true;
  zramSwap.numDevices = 2;

}
