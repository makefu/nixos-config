{ config, lib, pkgs, modulesPath, ... }:
{

  imports =
    [ ./network.nix
      (modulesPath + "/profiles/qemu-guest.nix")
    ];

  # Disk
  boot.initrd.availableKernelModules = [ "ata_piix" "virtio_pci" "virtio_scsi" "xhci_pci" "sr_mod" "virtio_blk" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "tank/root";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "tank/home";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "tank/nix";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/AEF3-A486";
      fsType = "vfat";
    };

  swapDevices = [ ];
  boot.loader.grub.device = "/dev/vda";

  networking.hostId = "3150697c"; # required for zfs use
  boot.tmpOnTmpfs = true;
  boot.supportedFilesystems = [ "zfs" ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.copyKernels = true;
  boot.zfs.devNodes = "/dev"; # fixes some virtualmachine issues
  boot.kernelParams = [
    "boot.shell_on_fail"
    "panic=30" "boot.panic_on_fail" # reboot the machine upon fatal boot issues
  ];
}
