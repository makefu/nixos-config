{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.makefu.tinc_graphs;
  internal_dir = "${cfg.workingDir}/internal";
  external_dir = "${cfg.workingDir}/external";

  out = {
    options.makefu.tinc_graphs = api;
    config = mkIf cfg.enable imp;
  };

  api = {
    enable = mkEnableOption "makefu.tinc_graphs";

    geodbPath = mkOption {
      type = types.str;
      description = "Path to geocitydb, defaults to geolite-legacy";
      default = "${geolite-legacy}/share/GeoIP/GeoIPCity.dat";
    };

    workingDir = mkOption {
      type = types.str;
      description = ''
        Path to working dir, will create interal and external/.
        Defaults to the new users home dir which defaults to
        /var/cache/tinc_graphs'';
      default = users.extraUsers.tinc_graphs.home;
    };

    timerConfig = mkOption {
      type = with types; attrsOf str;
      default = {
        OnCalendar = "*:0/15";
      };
    };
  };

  imp = {

    systemd.timers.tinc_graphs = {
      description = "Build Tinc Graphs via via timer";

      timerConfig = cfg.timerConfig;
    };
    systemd.services.tinc_graphs = {
      description = "Build Tinc Graphs";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      restartIfChanged = true;

      serviceConfig = {
        Type = "simple";
        environment = {
          EXTERNAL_FOLDER = external_dir;
          INTERNAL_FOLDER = internal_dir;
          GEODB = cfg.geodbPath;
        };
        ExecStartPre = ''
          #!/bin/sh
          mkdir -p "$EXTERNAL_FOLDER" "$INTERNAL_FOLDER"
        '';
        ExecStart = "${pkgs.tinc_graphs}/bin/all-the-graphs";
        User = "tinc_graphs";
        privateTmp = true;
      };
    };

    users.extraUsers.tinc_graphs = {
      uid = 3925439960; #genid tinc_graphs
      home = "/var/cache/tinc_graphs";
      createHome = true;
    };
  };

in
out
