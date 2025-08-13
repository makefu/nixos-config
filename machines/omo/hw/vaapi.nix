{ pkgs, ... }:
{
  boot.kernelParams = [ "i915.enable_guc=2" ]; # according to https://discourse.nixos.org/t/intel-media-sdk-has-become-deprecated/66998/6
  # 2024-08-18: https://wiki.nixos.org/wiki/Jellyfin
  hardware.graphics = { # hardware.opengl in 24.05
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver # previously vaapiIntel
      vaapiVdpau
      intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
      vpl-gpu-rt # QSV on 11th gen or newer
      #intel-media-sdk # QSV up to 11th gen # deprecated since 2025-07-05
      #intel-compute-runtime-legacy1
    ];
  };

}
