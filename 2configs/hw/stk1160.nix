{ pkgs, lib, ... }:
{
  # TODO: un-pin linuxPackages somehow
  nixpkgs.config.packageOverrides = pkgs: {
    linux_4_14 = pkgs.linux_4_14.override {
        extraConfig = ''
          MEDIA_ANALOG_TV_SUPPORT y
          VIDEO_STK1160_COMMON m
          VIDEO_STK1160 m
        '';
    };
  };
}
