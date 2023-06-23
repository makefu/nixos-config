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
    # ../../../2configs/hw/xmm7360.nix
    nixos-hardware.nixosModules.lenovo-thinkpad-l14-amd
  ];

  boot.kernelPackages = lib.mkForce pkgs.linuxPackages;

  services.fwupd.enable = true;
  programs.light.enable = true;

  boot.extraModprobeConfig = ''
    options thinkpad_acpi fan_control=1
  '';
}

