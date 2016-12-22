{ config, pkgs, ... }:
{
    imports = [
        ../.
        # configure your hw:
        # ../2configs/hw/CAC.nix
        # ../2configs/fs/CAC-CentOS-7-64bit.nix
      ../2configs/save-diskspace.nix
      ../2configs/tinc/retiolum.nix

    ];
    krebs = {
        enable = true;
        build.host = config.krebs.hosts.fileleech;
    };

		boot.loader.grub.enable = true;
		boot.loader.grub.version = 2;
    boot.loader.grub.device = "/dev/disk/by-id/ata-INTEL_SSDSA2M080G2GC_CVPO003402PB080BGN";
    fileSystems."/" = {
        device = "/dev/disk/by-id/ata-INTEL_SSDSA2M080G2GC_CVPO003402PB080BGN";
    };

		boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ahci" "aacraid" "usb_storage" "usbhid" ];
		boot.kernelModules = [ "kvm-intel" ];
		boot.extraModulePackages = [ ];
}
