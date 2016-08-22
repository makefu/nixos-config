{ config, lib, pkgs, ... }:

with config.krebs.lib;
let
  cfg = config.makefu.opentracker;

  out = {
    options.makefu.opentracker = api;
    config = lib.mkIf cfg.enable imp;
  };

  api = {
    enable = mkEnableOption "opentracker";

    package = mkOption {
      type = types.package;
      default = pkgs.opentracker;
    };

    args = mkOption {
      type = types.string;
      description = ''
        see https://erdgeist.org/arts/software/opentracker/ for all params
      '';
      default = "";
    };

    user = mkOption {
      description = ''
        user which will run opentracker. by default opentracker drops all
        privileges and runs in chroot after starting up as root.
      '';
      type = types.str;
      default = "root";
    };
  };

  imp = {
    systemd.services.opentracker = {
      description = "opentracker server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      restartIfChanged = true;
      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/opentracker ${cfg.args}";
        PrivateTmp = true;
        WorkingDirectory = "/tmp";
        User = "${cfg.user}";
      };
    };
  };
in
out

