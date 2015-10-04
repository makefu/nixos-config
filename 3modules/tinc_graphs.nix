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

    krebsNginx = {
      # configure krebs nginx to serve the new graphs
      enable = mkEnableOption "tinc_graphs nginx";

      hostnames_complete = mkOption {
        #TODO: this is not a secure way to serve these graphs,better listen to
        #      the correct interface, krebs.nginx does not support this yet

        type = with types; listOf str;
        description = "hostname which serves complete graphs";
        default = [ "graphs.${config.krebs.build.host.name}" ];
      };

      hostnames_anonymous = mkOption {
        type = with types; listOf str;
        description = ''
          hostname which serves anonymous graphs
          must be different from hostname_complete
        '';
        default = [ "anongraphs.${config.krebs.build.host.name}" ];
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

      timerConfig = cfg.timerConfig;
    };
    systemd.services.tinc_graphs = {
      description = "Build Tinc Graphs";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
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
          mkdir -p "${external_dir}" "${internal_dir}"
        '';

        ExecStart = "${pkgs.tinc_graphs}/bin/all-the-graphs";

        ExecStartPost = pkgs.writeScript "tinc_graphs-post" ''
          #!/bin/sh
          # TODO: this may break if workingDir is set to something stupid
          # this is needed because homedir is created with 700
          chmod 755  "${cfg.workingDir}"
        '';

        User = "root"; # tinc cannot be queried as user,
                       #  seems to be a tinc-pre issue
        privateTmp = true;
      };
    };

    users.extraUsers.tinc_graphs = {
      uid = 3925439960; #genid tinc_graphs
      home = "/var/spool/tinc_graphs";
      createHome = true;
    };

    krebs.nginx.servers = mkIf cfg.krebsNginx.enable {
      tinc_graphs_complete = {
        server-names = cfg.krebsNginx.hostnames_complete;
        locations = [
          (nameValuePair "/" ''
            autoindex on;
            root ${internal_dir};
          '')
        ];
      };
      tinc_graphs_anonymous = {
        server-names = cfg.krebsNginx.hostnames_anonymous;
        locations = [
          (nameValuePair "/" ''
            autoindex on;
            root ${external_dir};
          '')
        ];
      };
    };
  };

in
out
