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
  ];
  boot.zfs.requestEncryptionCredentials = true;
  networking.hostId = "f8b8e0a2";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # services.xserver.enable = lib.mkForce false;

  services.xserver.videoDrivers = [
    "amdgpu"
  ];
  hardware.opengl.extraPackages = [ pkgs.amdvlk ];
  # is required for amd graphics support ( xorg wont boot otherwise )
  boot.kernelPackages = pkgs.linuxPackages_latest;
  environment.variables.VK_ICD_FILENAMES =
    "/run/opengl-driver/share/vulkan/icd.d/amd_icd64.json";


  programs.light.enable = true;
  services.actkbd = {
    enable = true;
    bindings = [
      { keys = [ 225 ]; events = [ "key" ]; command = "${pkgs.light}/bin/light -A 10"; }
      { keys = [ 224 ]; events = [ "key" ]; command = "${pkgs.light}/bin/light -U 10"; }
      { keys = [ 227 ]; events = [ "key" ]; command = builtins.toString (
        pkgs.writers.writeDash "toggle_lcdshadow" ''
          proc=/proc/acpi/ibm/lcdshadow
          status=$(${pkgs.gawk}/bin/awk '/status:/{print $2}' "$proc")
          if [ "$status" -eq 0 ];then
            echo 1 > "$proc"
          else
            echo 0 > "$proc"
          fi
        '');
      }
    ];
  };

  users.groups.video = {};
  users.users.makefu.extraGroups = [ "video" ];
}

