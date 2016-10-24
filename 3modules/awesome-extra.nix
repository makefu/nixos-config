{config, lib, pkgs, ... }:

with import <stockholm/lib>;
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
      default = pkgs.awesomecfg.full;
    };
  };
  imp = {
    # TODO: configure display manager as well
    nixpkgs.config.packageOverrides = pkgs: rec {
      awesome = pkgs.stdenv.lib.overrideDerivation pkgs.awesome (oldAttrs : {
          postFixup = let 
            rclua = pkgs.substituteAll {
              src = cfg.baseConfig;
              inherit (cfg) modkey;
            };
          in "cp ${rclua}  $out/etc/xdg/awesome/rc.lua";
      });
    };
  };
in out
