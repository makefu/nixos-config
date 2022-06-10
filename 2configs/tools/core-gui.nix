{ pkgs, ... }:

{
  users.users.makefu.packages = with pkgs; [
    at_spi2_core
    chromium
    feh
    clipit
    # firefox
    keepassx
    pcmanfm
    evince
    # replacement for mirage:
    sxiv
    dconf
    xdotool
    xorg.xbacklight
    scrot
    libnotify
  ];
}
