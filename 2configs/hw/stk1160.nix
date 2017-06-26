{ pkgs, ... }:
{
  # TODO: un-pin linuxPackages somehow
  nixpkgs.config.packageOverrides = pkgs: {
    linux_latest = pkgs.linux_latest.override {
        extraConfig = ''
          MEDIA_ANALOG_TV_SUPPORT y
          VIDEO_STK1160_COMMON m
          VIDEO_STK1160_AC97 y
          VIDEO_STK1160 m
        '';
    };
  };
}
