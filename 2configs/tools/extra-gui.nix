{ pkgs, ... }:

{
  state = [
      "/home/makefu/.config/Element"
  ];
  users.users.makefu.packages = with pkgs;[
    # media
    gimp
    # mirage - last time available in 19.09
    inkscape
    libreoffice
    guake
    # skype
    # teams
    synergy
    telegram-desktop
    virt-manager
    #jellyfin-media-player
    # Dev
    saleae-logic
    git
    signal-desktop
    element-desktop
    # rambox

    vscode

    # 3d Modelling
    # chitubox
    # freecad
  ];
}
