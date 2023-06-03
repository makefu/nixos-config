{ pkgs, ... }:

{
  users.users.makefu.packages = with pkgs; [
    at-spi2-core
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
    thunderbird
  ];
}
