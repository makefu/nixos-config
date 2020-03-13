{ pkgs, ... }:

{
  users.users.makefu.packages = with pkgs;[
    # media
    gimp
    mirage
    inkscape
    libreoffice
    # skype
    synergy
    tdesktop
    virtmanager
    # Dev
    saleae-logic
    gitAndTools.gitFull
    signal-desktop
    # rambox
  ];
}
