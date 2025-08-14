{ pkgs, ... }:

{
    state = [
        "/home/makefu/.mozilla"
        "/home/makefu/.thunderbird"

    ];
  users.users.makefu.packages = with pkgs; [
    at-spi2-core
    chromium
    feh
    clipit
    # firefox
    (pkgs.writers.writeDashBin "privatefox" "exec firefox -P Privatefox")
    kdePackages.dolphin
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
