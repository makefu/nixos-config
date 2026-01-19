{ pkgs, config, lib, ... }:
{
# the overwritten bambu-studio from 5pkgs does not come with a desktop entry
# it is easier to define it here
  home-manager.users.makefu.xdg.desktopEntries = {
    bambu-studio = {
      name = "Bambu Studio";
      exec = "${pkgs.bambu-studio}/bin/bambu-studio";
    };
  };
  #i18n.extraLocales = [ "en_GB.UTF-8/UTF-8" ];
  #i18n.defaultLocale = "en_US.UTF-8" ;
  i18n.defaultLocale = lib.mkForce "en_GB.UTF-8";

i18n.supportedLocales = [
  "en_GB.UTF-8/UTF-8"
  "en_US.UTF-8/UTF-8"
];
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
    # chitubox
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
