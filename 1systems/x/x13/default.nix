{ pkgs, lib, ... }:
# new zfs deployment
{
  imports = [
    ./zfs.nix
    ./input.nix
    <stockholm/makefu/2configs/hw/bluetooth.nix>
    <nixos-hardware/lenovo/thinkpad/l14/amd> # close enough
    # <stockholm/makefu/2configs/hw/tpm.nix>
    <stockholm/makefu/2configs/hw/ssd.nix>
    # <stockholm/makefu/2configs/hw/xmm7360.nix>
  ];
  boot.zfs.requestEncryptionCredentials = true;
  networking.hostId = "f8b8e0a2";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # services.xserver.enable = lib.mkForce false;

  services.xserver.videoDrivers = [
    "amdgpu"
  ];
  hardware.opengl.extraPackages = [ pkgs.amdvlk pkgs.rocm-opencl-icd ];
  # is required for amd graphics support ( xorg wont boot otherwise )
  #boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages;

  environment.variables.VK_ICD_FILENAMES =
    "/run/opengl-driver/share/vulkan/icd.d/amd_icd64.json";

  services.fwupd.enable = true;

  programs.light.enable = true;

  users.groups.video = {};
  users.users.makefu.extraGroups = [ "video" ];

  boot.extraModprobeConfig = ''
    options thinkpad_acpi fan_control=1
  '';
}

