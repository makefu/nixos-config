{ pkgs, ... }:
with builtins;
let
  disko = import (builtins.fetchGit {
    url = https://cgit.lassul.us/disko/;
    rev = "9c9b62e15e4ac11d4379e66b974f1389daf939fe";
  });
  cfg = fromJSON (readFile ../../hardware/tsp-disk.json);
  primaryInterface = "enp1s0";
  rootDisk = "/dev/sda"; # TODO same as disko uses
in {
  imports = [
    (disko.config cfg)
  ];
  makefu.server.primary-itf = primaryInterface;
  boot = {
    loader.grub.device = rootDisk;

    initrd.availableKernelModules = [
      "ahci"
      "ohci_pci"
      "ehci_pci"
      "pata_atiixp"
      "firewire_ohci"
      "usb_storage"
      "usbhid"
    ];

    kernelModules = [ "kvm-intel" ];
  };
  networking.wireless.enable = true;
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;
  services.logind.lidSwitch = "ignore";
  services.logind.lidSwitchDocked = "ignore";
  services.logind.extraConfig = ''
    HandleSuspendKey = ignore
  '';
  powerManagement.enable = false;
}
