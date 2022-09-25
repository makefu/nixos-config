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


let
  mainUser = config.krebs.build.user.name;
in
{
  imports = [
    ./urxvtd.nix
    ./pipewire.nix
  ];


  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "altgr-intl";
    xkbOptions = "ctrl:nocaps, eurosign:e";

    windowManager = {
      awesome.enable = true;
      awesome.noArgb = true;
      awesome.luaModules = [ pkgs.luaPackages.vicious ];
    };
    displayManager.defaultSession = lib.mkDefault "none+awesome";
    displayManager.autoLogin = {
      enable = true;
      user = mainUser;
    };
  };
  environment.systemPackages = [ pkgs.gnome.adwaita-icon-theme ];
  # lid switch is handled via button presses
  services.logind.lidSwitch = lib.mkDefault "ignore";
  makefu.awesome.enable = true;
  console.font = "Lat2-Terminus16";

  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    fonts = [ pkgs.terminus_font pkgs.corefonts ];
  };

  users.users.${mainUser} = {
    extraGroups = [ "pipewire" "audio" ];
    packages = with pkgs;[
      pavucontrol
      xlockmore
      rxvt_unicode-with-plugins
    ];
  };

  services.xserver.displayManager.sessionCommands = let
    xdefaultsfile = pkgs.writeText "Xdefaults"  ''
      cat |derp <<EOF
      XTerm*background: black
      XTerm*foreground: white
      XTerm*FaceName  : xft:Terminus:pixelsize=12

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
      URxvt.font : xft:Terminus:size=12
      URxvt.perl-ext-common: default,-confirm-paste


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
