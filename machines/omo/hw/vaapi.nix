{ pkgs, ... }:
let
  vaapi = pkgs.vaapiIntel.override { enableHybridCodec = true; };
in
{
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapi              # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ vaapi ];
  environment.systemPackages = [ pkgs.libva-utils ];
}
