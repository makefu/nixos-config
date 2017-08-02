{ pkgs, ... }:
{
  # TODO: un-pin linuxPackages somehow
  boot.kernelPackages = builtins.trace "Warning: overriding kernel Packages with 4.9" pkgs.linuxPackages;
  nixpkgs.config.packageOverrides = pkgs: {
    linux_4_9 = pkgs.linux_4_9.override {
        extraConfig = ''
          MEDIA_ANALOG_TV_SUPPORT y
          VIDEO_STK1160_COMMON m
          VIDEO_STK1160_AC97 y
          VIDEO_STK1160 m
        '';
    };
  };
}
