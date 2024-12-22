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
    # cura
    bambu-studio
  ];
  networking.firewall.allowedUDPPorts = [
    1990 2021 # bambu-studio ssdp
  ];
  networking.firewall.allowedTCPPorts = [
    8883 6000 # bambu-studio lan mode
  ];
  xdg.portal.enable = true;
  #xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
}
