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


with import <stockholm/lib>;
let
  mainUser = config.krebs.build.user.name;
in
{
  imports = [
    ./urxvtd.nix
  ];

  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "altgr-intl";
    xkbOptions = "ctrl:nocaps, eurosign:e";

    windowManager = {
      awesome.enable = true;
      awesome.luaModules = [ pkgs.luaPackages.vicious ];
      default = "awesome";
    };

    displayManager.auto.enable = true;
    displayManager.auto.user = mainUser;
    desktopManager.xterm.enable = false;
  };
  # lid switch is handled via button presses
  services.logind.extraConfig = mkDefault "HandleLidSwitch=ignore";
  makefu.awesome.enable = true;
  i18n.consoleFont = "Lat2-Terminus16";

  fonts = {
    enableCoreFonts = true;
    enableFontDir = true;
    enableGhostscriptFonts = true;
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
     systemWide = true;
  };
  services.xserver.displayManager.sessionCommands = let
    xdefaultsfile = pkgs.writeText "Xdefaults"  ''
      cat |derp <<EOF
      XTerm*background: black
      XTerm*foreground: white
      XTerm*FaceName  : xft:xos4 Terminus:pixelsize=11

      URxvt*termName:         rxvt
      URxvt*saveLines:            10000
      URxvt*loginShell:           false
      URxvt.scrollBar : false
      URxvt*scrollBar_right:  false
      URxvt*borderLess:       false
      URxvt.foreground: white
      URxvt.background: black
      URxvt.urgentOnBell: true
      URxvt.visualBell: false
      URxvt.font : xft:xos4 Terminus:size=11


      ! blue
      URxvt*color4:                         #268bd2


      URxvt.perl-ext:      default,url-select
      URxvt.keysym.M-u:    perl:url-select:select_next
      URxvt.url-select.launcher:   firefox -new-tab
      URxvt.url-select.underline: true
      URxvt.searchable-scrollback: CM-s
    '';
    in ''
      cat ${xdefaultsfile} | xrdb -merge
      ${pkgs.xorg.xhost}/bin/xhost +local:
    '';
}
