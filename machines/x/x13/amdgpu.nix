{ pkgs, ... }:
{
  services.xserver.videoDrivers = [ "amdgpu" ];
  #boot.initrd.kernelModules = [ "amdgpu" ];
  hardware.opengl.driSupport = true;
  hardware.opengl.extraPackages = [ pkgs.amdvlk pkgs.rocm-opencl-icd pkgs.rocm-opencl-runtime ];
  # For 32 bit applications
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];
  # is required for amd graphics support ( xorg wont boot otherwise )
  users.groups.video = {};
  users.groups.render = {};
  users.users.makefu.extraGroups = [ "video" "render" ];
}
