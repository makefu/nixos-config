{ config, lib, pkgs, ... }:

let
  mainUser = config.krebs.build.user.name;
in
{
  programs.gnome-terminal.enable = true;
  services.xserver = {
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
    #displayManager.autoLogin = {
    #  enable = true;
    #  user = mainUser;
    #};
  };
  home-manager.users.${mainUser}.services.gammastep = {
    enable = true;
    provider = "manual";
    latitude = config.location.latitude;
    longitude = config.location.longitude;
  };
}
