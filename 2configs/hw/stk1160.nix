{ pkgs, lib, ... }:
{
  boot.kernelPatches = lib.singleton {
    name = "enable-stk1160";
    patch = null;
    extraConfig = ''
      MEDIA_ANALOG_TV_SUPPORT y
      VIDEO_STK1160_COMMON m
      VIDEO_STK1160 m
    '';
  };
}
