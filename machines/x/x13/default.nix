{ pkgs, lib, nixos-hardware, self, ... }:
# new zfs deployment
{
  imports = [
    ./input.nix
    
    ((import  ../../../2configs/fs/disko/single-disk-encrypted-zfs.nix ) { disks ="/dev/nvme0n1"; hostId = "f8b8e0a3"; })
    ./battery.nix
    ./amdgpu.nix
    ../../../2configs/hw/bluetooth.nix
    ../../../2configs/hw/tpm.nix
    ../../../2configs/hw/ssd.nix
    ./secureboot.nix
    # ../../../2configs/hw/xmm7360.nix
    nixos-hardware.nixosModules.lenovo-thinkpad-l14-amd
  ];

  swapDevices = [ ];
  zramSwap.enable = true;
  boot.initrd.availableKernelModules = [ "nvme" "ehci_pci" "xhci_pci" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [
    "amd_pstate=active"
  ];


  boot.kernelPackages = lib.mkForce pkgs.linuxPackages;

  services.fwupd.enable = true;
  programs.light.enable = true;

  boot.extraModprobeConfig = ''
    options thinkpad_acpi fan_control=1
  '';

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

}

