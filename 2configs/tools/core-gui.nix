{ pkgs, ... }:

{
  users.users.makefu.packages = with pkgs; [
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
