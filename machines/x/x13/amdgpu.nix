{ pkgs, ... }:
{
  services.xserver.videoDrivers = [ "amdgpu" ];
  #boot.initrd.kernelModules = [ "amdgpu" ];
  #hardware.opengl.driSupport = true;
  hardware.graphics.extraPackages = with pkgs; [ amdvlk 
    # rocmPackages.clr.icd rocmPackages.clr # does not build (2025-01-11)
  ];
  # For 32 bit applications
  hardware.graphics.enable32Bit = true; 
  hardware.graphics.extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];
  # is required for amd graphics support ( xorg wont boot otherwise )
  users.groups.video = {};
  users.groups.render = {};
  users.users.makefu.extraGroups = [ "video" "render" ];
}
