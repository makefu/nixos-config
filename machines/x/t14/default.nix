{ pkgs, config, lib, nixos-hardware, self, ... }:
{
  imports = [
    ./input.nix
    
    # arcMax over the 8G default: 8G sat pegged full on this 30G box.
    ((import  ../../../2configs/fs/disko/single-disk-encrypted-zfs.nix ) { disks ="/dev/nvme0n1"; hostId = "f8b8e0a3"; arcMax = 12884901888; inherit config; })
    ./battery.nix
    ./memory.nix
    ./power-limits.nix
    ../../../2configs/hw/bluetooth.nix
    ../../../2configs/hw/tpm.nix
    ../../../2configs/hw/ssd.nix
    ./secureboot.nix
    # ../../../2configs/hw/xmm7360.nix
    ./nvidia.nix
  ];
  #hardware.facter.reportPath = ./facter.json ;
  swapDevices = [ ];
  #zramSwap.enable = true;
  boot.initrd.availableKernelModules = [ "rtsx_pci_sdmmc" "nvme" "ehci_pci" "xhci_pci" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.tmp.useTmpfs = true;
  # zfs 2.4.4 supports kernels up to 7.2; linuxPackages_latest is 7.3.1 and
  # zfs configure fails on the iops->create() change (openzfs/zfs#19032).
  # Bump back to latest once openzfs supports 7.3.
  boot.kernelPackages = pkgs.linuxPackages_7_2;

  services.fwupd.enable = true;

  boot.extraModprobeConfig = ''
    options thinkpad_acpi fan_control=1
  '';

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  systemd.tmpfiles.settings."10-fan-control-for-makefu" = {
    "/proc/acpi/ibm/fan".f = {
      user = "makefu";
      group = "root";
    };
  };
}

