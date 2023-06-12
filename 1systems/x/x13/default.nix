{ pkgs, lib, nixos-hardware, self, ... }:
# new zfs deployment
{
  imports = [
    ./input.nix
    ./disk.nix
    ./battery.nix

    (self + "/2configs/hw/bluetooth.nix")
    (self + "/2configs/hw/tpm.nix")
    (self + "/2configs/hw/ssd.nix")
    # (self + "/2configs/hw/xmm7360.nix")

    nixos-hardware.nixosModules.lenovo-thinkpad-l14-amd

  ];
  boot.zfs.requestEncryptionCredentials = true;
  networking.hostId = "f8b8e0a2";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # services.xserver.enable = lib.mkForce false;

  services.xserver.videoDrivers = [ "amdgpu" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  hardware.opengl.driSupport = true;
  hardware.opengl.extraPackages = [ pkgs.amdvlk pkgs.rocm-opencl-icd pkgs.rocm-opencl-runtime ];
  # For 32 bit applications
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];
  # is required for amd graphics support ( xorg wont boot otherwise )
  #boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages;

  services.fwupd.enable = true;

  programs.light.enable = true;

  users.groups.video = {};
  users.groups.render = {};
  users.users.makefu.extraGroups = [ "video" "render" ];

  boot.extraModprobeConfig = ''
    options thinkpad_acpi fan_control=1
  '';
}

