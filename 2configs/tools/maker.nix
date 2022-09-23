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
    cura
    chitubox
  ];
}
