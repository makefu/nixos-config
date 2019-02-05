{ pkgs, ... }:

{
  users.users.makefu.packages = with pkgs; [
    at_spi2_core
    chromium
    feh
    clipit
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
