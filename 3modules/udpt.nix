{ config, lib, pkgs, ... }:

with config.krebs.lib;
let
  cfg = config.makefu.udpt;

  out = {
    options.makefu.udpt = api;
    config = lib.mkIf cfg.enable imp;
  };

  api = {
    enable = mkEnableOption "udpt";

    package = mkOption {
      type = types.package;
      default = pkgs.udpt;
    };

    cfgfile = mkOption {
      type = types.path;
      default = "${cfg.package}/etc/udpt.conf";
    };

    user = mkOption {
      description = ''
        user which will run udpt. if kept default a new user will be created
      '';
      type = types.str;
      default = "udpt";
    };

  };

  imp = {
    systemd.services.udpt = {
      description = "udpt server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      restartIfChanged = true;
      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/udpt -c ${shell.escape cfg.cfgfile}";
        PrivateTmp = true;
        User = "${cfg.user}";
      };
    };
    users = lib.mkIf (cfg.user == "udpt") {
      users.udpt = {
        uid = genid "udpt";
      };
      groups.udpt.gid = genid "udpt";
    };
  };
in
out

