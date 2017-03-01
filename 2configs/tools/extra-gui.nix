{ pkgs, ... }:

{
  krebs.per-user.makefu.packages = with pkgs;[
    inkscape
    gimp
    skype
    virtmanager
    synergy
    saleae-logic
  ];
}
