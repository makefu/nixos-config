{ config, lib, pkgs, ... }:
##
# of course this name is a lie - it prepares a GUI environment close to my
# current configuration.
#
# autologin with mainUser into awesome
##
#
with lib;
let
  mainUser = config.krebs.build.user.name;
in
{
  imports = [ ];
  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "altgr-intl";
    xkbOptions = "ctrl:nocaps";

    windowManager = {
      awesome.enable = true;
      awesome.luaModules = [ pkgs.luaPackages.vicious ];
      default = "awesome";
    };

    displayManager.auto.enable = true;
    displayManager.auto.user = mainUser;
    desktopManager.xterm.enable = false;
  };
  services.redshift = {
    enable = true;
    latitude = "48.7";
    longitude = "9.1";
  };

## FONTS
# TODO: somewhere else?

  i18n.consoleFont = "Lat2-Terminus16";

  fonts = {
    enableCoreFonts = true;
    enableFontDir = true;
    enableGhostscriptFonts = false;
    fonts = [ pkgs.terminus_font ];
  };

  environment.systemPackages = with pkgs;[
    xlockmore
    rxvt_unicode-with-plugins
    vlc
    firefox
    chromium
  ];
  # TODO: use mainUser
  users.extraUsers.makefu.extraGroups = [ "audio" ];
  hardware.pulseaudio = {
    enable = true;
  #  systemWide = true;
  };
}
