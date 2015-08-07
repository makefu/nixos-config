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

  environment.systemPackages = [
    pkgs.xlockmore
    pkgs.rxvt_unicode-with-plugins
  ];

  hardware.pulseaudio = {
    enable = true;
    systemWide = true;
  };

}
