{ pkgs, modulesPath, lib, nixos-hardware, self, ... }:
# new zfs deployment
{
  imports = [
    ((import  ./disk-setup.nix ) { disks = [ "/dev/sda" "/dev/sdb"]; })
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  swapDevices = [ ];

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages;
  services.qemuGuest.enable = true;
}

