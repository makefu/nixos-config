{ pkgs, ... }:

{
  krebs.per-user.makefu.packages = with pkgs;[
    gimp
    inkscape
    libreoffice
    saleae-logic
    skype
    synergy
    tdesktop
    virtmanager
  ];
}
