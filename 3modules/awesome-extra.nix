{config, lib, pkgs, ... }:

with lib;
let
  cfg = config.makefu.awesome;
  out = {
    options.makefu.awesome = api;
    config = lib.mkIf cfg.enable imp;
  };
  api = {
    enable = mkEnableOption "awesome custom config";
    modkey = mkOption {
      type = types.str;
      description = "Modkey to be used";
      default = "Mod4";
    };
    baseConfig = mkOption {
      type = types.path;
      description = ''
        rc.lua file to be used as default
        This module will use substituteAll to replace strings before writing to
        /etc/xdg/awesome/rc.lua
      '';
      default = pkgs.awesomecfg.full.override {
        locker = "${pkgs.i3lock}/bin/i3lock -i /var/lib/wallpaper/wallpaper";
      };
    };
  };
  imp = {
    home-manager.users.makefu.home.file.".config/awesome/rc.lua".source =
      cfg.baseConfig.override {
        inherit (cfg) modkey;
      };

  };
in out
