{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
let
  cfg = config.makefu.ps3netsrv;

  out = {
    options.makefu.ps3netsrv = api;
    config = lib.mkIf cfg.enable imp;
  };

  api = {
    enable = mkEnableOption "ps3netsrv";

    servedir = mkOption {
      description = "path to serve, must be set";
      type = types.str;
    };

    package = mkOption {
      type = types.package;
      default = pkgs.ps3netsrv;
    };

    user = mkOption {
      description = ''user which will run ps3netsrv'';
      type = types.str;
      default = "ps3netsrv";
    };
  };

  imp = {
    systemd.services.ps3netsrv = {
      description = "ps3netsrv server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      restartIfChanged = true;
      unitConfig = {
        Documentation = "https://www.arm-blog.com/playing-ps3-games-from-your-nas/" ;
        ConditionPathExists = cfg.servedir;
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/ps3netsrv++ ${shell.escape cfg.servedir}";
        PrivateTmp = true;
        User = "${cfg.user}";
      };
    };

    # TODO only create if user is ps3netsrv
    users.users.ps3netsrv = {
      uid = genid "ps3netsrv";
      isSystemUser = true;
      group = "ps3netsrv";
    };
    users.groups.ps3netsrv.gid = genid "ps3netsrv";
  };
in
out

