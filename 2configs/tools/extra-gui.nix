{ pkgs, ... }:

{
  users.users.makefu.packages = with pkgs;[
    # media
    gimp
    inkscape
    libreoffice
    quodlibet
    # skype
    synergy
    tdesktop
    virtmanager
    # Dev
    saleae-logic
    gitAndTools.gitFull
    signal-desktop
  ];
}
