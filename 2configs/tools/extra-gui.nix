{ pkgs, ... }:

{
  krebs.per-user.makefu.packages = with pkgs;[
    # media
    gimp
    inkscape
    libreoffice
    skype
    synergy
    tdesktop
    virtmanager
    # Dev
    saleae-logic
    arduino-user-env
    gitAndTools.gitFull
  ];
}
