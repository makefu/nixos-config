{ pkgs, ... }:
{
  users.users.makefu.packages = with pkgs; [
    # media
    picard
    asunder
    #darkice
    lame
    # creation
    blender
    openscad
    # slicing
    #cura
    chitubox
    cura
  ];
  xdg.portal.enable = true;
  #xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
}
