{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
let
  cfg = config.makefu.taskserver;

  out = {
    options.makefu.taskserver = api;
    config = lib.mkIf cfg.enable imp;
  };

  api = {
    enable = mkEnableOption "taskserver";

    workingDir = mkOption {
      type = types.str;
      default = "/var/lib/taskserver";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.taskserver;
    };


  };

  imp = {
    environment.systemPackages = [ cfg.package ];
    systemd.services.taskserver = {
      description = "taskd server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      restartIfChanged = true;
      unitConfig = {
        Documentation = "http://taskwarrior.org/docs/#taskd" ;
        # https://taskwarrior.org/docs/taskserver/configure.html
        ConditionPathExists = "${cfg.workingDir}/config";
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/taskd server --data ${cfg.workingDir}";
        WorkingDirectory = cfg.workingDir;
        PrivateTmp = true;
        InaccessibleDirectories = "/home /boot /opt /mnt /media";
        User = "taskd";
      };
    };

    users.users.taskd = {
      uid = genid "taskd";
      home = cfg.workingDir;
      createHome = true;
    };
    users.groups.taskd.gid = genid "taskd";
  };

in
out

