{ pkgs, config, lib, nixos-hardware, self, ... }:
{
  imports = [
    ./input.nix
    
    ((import  ../../../2configs/fs/disko/single-disk-encrypted-zfs.nix ) { disks ="/dev/nvme0n1"; hostId = "f8b8e0a3"; inherit config; })
    ./battery.nix
    ../../../2configs/hw/bluetooth.nix
    ../../../2configs/hw/tpm.nix
    ../../../2configs/hw/ssd.nix
    ./secureboot.nix
    # ../../../2configs/hw/xmm7360.nix
    nixos-hardware.nixosModules.lenovo-thinkpad-t14-gen1-nvidia
  ];

  swapDevices = [ ];
  zramSwap.enable = true;
  boot.initrd.availableKernelModules = [ "rtsx_pci_sdmmc" "nvme" "ehci_pci" "xhci_pci" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.tmp.useTmpfs = true;
  # boot.kernelPackages = lib.mkForce pkgs.linuxPackagesLatest;

  services.fwupd.enable = true;
  programs.light.enable = true;

  boot.extraModprobeConfig = ''
    options thinkpad_acpi fan_control=1
  '';

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

