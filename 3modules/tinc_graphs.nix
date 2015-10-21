{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.makefu.tinc_graphs;
  internal_dir = "${cfg.workingDir}/internal";
  external_dir = "${cfg.workingDir}/external";

  out = {
    options.makefu.tinc_graphs = api;
    config = mkIf cfg.enable imp ;
  };

  api = {
    enable = mkEnableOption "tinc graphs";

    geodbPath = mkOption {
      type = types.str;
      description = "Path to geocitydb, defaults to geolite-legacy";
      default = "${pkgs.geolite-legacy}/share/GeoIP/GeoIPCity.dat";
    };

    nginx = {
      enable = mkEnableOption "enable tinc_graphs to be served with nginx";

      anonymous = {
        server-names = mkOption {
          type = with types; listOf str;
          description = "hostnames which serve anonymous graphs";
          default = [ "graphs.${config.krebs.build.host.name}" ];
        };

        listen = mkOption {
          # use the type of the nginx listen option
          type = with types; listOf str;
          description = "listen address for anonymous graphs";
          default = [ "80" ];
        };

      };

      complete = {
        server-names = mkOption {
          type = with types; listOf str;
          description = "hostname which serves complete graphs";
          default = [ "graphs.${config.krebs.build.host.name}" ];
        };

        listen = mkOption {
          type = with types; listOf str;
          description = "listen address for complete graphs";
          default = [ "127.0.0.1:80" ];
        };

      };
    };

    workingDir = mkOption {
      type = types.str;
      description = ''
        Path to working dir, will create interal and external/.
        Defaults to the new users home dir which defaults to
        /var/cache/tinc_graphs'';
      default = config.users.extraUsers.tinc_graphs.home;
    };

    timerConfig = mkOption {
      type = with types; attrsOf str;
      default = {
        OnCalendar = "*:0/15";
      };
    };
  };

  imp = {
    environment.systemPackages = [ pkgs.tinc_graphs];
    systemd.timers.tinc_graphs = {
      description = "Build Tinc Graphs via via timer";
      wantedBy = [ "timers.target"];
      timerConfig = cfg.timerConfig;
    };
    systemd.services.tinc_graphs = {
      description = "Build Tinc Graphs";
      environment = {
        EXTERNAL_FOLDER = external_dir;
        INTERNAL_FOLDER = internal_dir;
        GEODB = cfg.geodbPath;
        TINC_HOSTPATH=config.krebs.retiolum.hosts;
      };

      restartIfChanged = true;

      serviceConfig = {
        Type = "simple";

        ExecStartPre = pkgs.writeScript "tinc_graphs-init" ''
          #!/bin/sh
          if ! test -e "${cfg.workingDir}/internal/index.html"; then
            cp -fr "$(${pkgs.tinc_graphs}/bin/tincstats-static-dir)/internal/" "${internal_dir}"
          fi
        '';

        ExecStart = "${pkgs.tinc_graphs}/bin/all-the-graphs";

        ExecStartPost = pkgs.writeScript "tinc_graphs-post" ''
          #!/bin/sh
          # TODO: this may break if workingDir is set to something stupid
          # this is needed because homedir is created with 700
          chmod 755  "${cfg.workingDir}"
        '';
        PrivateTmp = "yes";

        User = "root"; # tinc cannot be queried as user,
                       #  seems to be a tinc-pre issue
      };
    };

    users.extraUsers.tinc_graphs = {
      uid = 3925439960; #genid tinc_graphs
      home = "/var/spool/tinc_graphs";
      createHome = true;
    };

    krebs.nginx.servers = mkIf cfg.nginx.enable {
      tinc_graphs_complete = mkMerge [ cfg.nginx.complete  {
        locations = [
          (nameValuePair "/" ''
            autoindex on;
            root ${internal_dir};
          '')
        ];
      }] ;
      tinc_graphs_anonymous = mkMerge [ cfg.nginx.anonymous {
        locations = [
          (nameValuePair "/" ''
            autoindex on;
            root ${external_dir};
          '')
        ];
      }];
    };
  };

in
out
