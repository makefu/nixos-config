{ pkgs, ... }:

{
  nixpkgs.config.firefox = {
    enableAdobeFlash = true;
  };

  krebs.per-user.makefu.packages = with pkgs; [
    chromium
    clipit
    feh
    firefox
    keepassx
    pcmanfm
    evince
    mirage
    tightvnc
    gnome3.dconf
    xdotool
    xorg.xbacklight
    scrot
  ];
}
