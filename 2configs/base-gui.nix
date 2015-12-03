{ config, lib, pkgs, ... }:
##
# of course this name is a lie
# - it prepares a GUI environment close to my
# current configuration,specifically:
#
# * autologin with mainUser into awesome
# * audio
# * terminus font
#
# if this is not enough, check out main-laptop.nix

## TODO: .Xdefaults:
# URxvt*termName:         rxvt
# URxvt.scrollBar : false
# URxvt*scrollBar_right:  false
# URxvt*borderLess:       false
# URxvt.foreground: white
# URxvt.background: black
# URxvt.urgentOnBell: true
# URxvt.visualBell: false
# URxvt.font : xft:Terminus

with lib;
let
  mainUser = config.krebs.build.user.name;
  awesomecfg = pkgs.awesomecfg.full;
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
  nixpkgs.config.packageOverrides = pkgs: rec {
    awesome = pkgs.stdenv.lib.overrideDerivation pkgs.awesome (oldAttrs : {
      postFixup = ''
      cp ${awesomecfg}  $out/etc/xdg/awesome/rc.lua
      '';
    });
  };

  i18n.consoleFont = "Lat2-Terminus16";

  fonts = {
    enableCoreFonts = true;
    enableFontDir = true;
    enableGhostscriptFonts = false;
    fonts = [ pkgs.terminus_font ];
  };

  environment.systemPackages = with pkgs;[
    pavucontrol
    xlockmore
    rxvt_unicode-with-plugins
    firefox
  ];
  users.extraUsers.${mainUser}.extraGroups = [ "audio" ];

  hardware.pulseaudio = {
     enable = true;
   #  systemWide = true;
  };
}
