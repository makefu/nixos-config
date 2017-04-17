{ pkgs, ... }:

{
  krebs.per-user.makefu.packages = with pkgs;[
    inkscape
    gimp
    libreoffice
    skype
    virtmanager
    synergy
    saleae-logic
  ];
}
