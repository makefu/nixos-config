{ pkgs, ... }:
{
    # omo has 7th generation  i5-7400T (kaby lake) from  Q1'17
    boot.kernelParams = [ "i915.enable_guc=2" ]; # according to https://discourse.nixos.org/t/intel-media-sdk-has-become-deprecated/66998/6

    # only required when intel-vaapi-driver
    #nixpkgs.config.packageOverrides = pkgs: {
    # vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
    #};
 environment.systemPackages = with pkgs;[
     libva-utils # vainfo
     clinfo # clinfo
     intel-gpu-tools # intel_gpu_top
 ];
   systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME = "iHD";
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };
  # 2024-08-18: https://wiki.nixos.org/wiki/Jellyfin
  hardware.graphics = { # hardware.opengl in 24.05
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # For Broadwell (2014) or newer processors. LIBVA_DRIVER_NAME=iHD
      # intel-vaapi-driver # For older processors. LIBVA_DRIVER_NAME=i965
      libva-vdpau-driver # Previously vaapiVdpau
      # OpenCL support for intel CPUs before 12th gen
      # see: https://github.com/NixOS/nixpkgs/issues/356535
	  # intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
      intel-compute-runtime-legacy1
      # vpl-gpu-rt # QSV on 11th gen or newer
      # deprecated
      # intel-media-sdk # QSV up to 11th gen
      intel-ocl # OpenCL support
    ];
  };

}
