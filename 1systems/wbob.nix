{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ../2configs/main-laptop.nix
    ];
    krebs = {
        enable = true;
        retiolum.enable = true;
        build.host = config.krebs.hosts.wbob;
    };
    boot.loader.grub.device = "/dev/sda";
    boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" ];
    boot.kernelModules = [ "kvm-intel" ];
    fileSystems."/" = {
        device = "/dev/sda1";
        fsType = "ext4";
    };
}
