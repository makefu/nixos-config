{ config, pkgs, lib, ... }:

with lib;
let
  buildbot-slave-init = pkgs.writeText "buildbot-slave.tac" ''
    import os

    from buildslave.bot import BuildSlave
    from twisted.application import service

    basedir = '${cfg.workDir}'
    rotateLength = 10000000
    maxRotatedFiles = 10

    application = service.Application('buildslave')

    from twisted.python.logfile import LogFile
    from twisted.python.log import ILogObserver, FileLogObserver
    logfile = LogFile.fromFullPath(os.path.join(basedir, "twistd.log"), rotateLength=rotateLength,
                                  maxRotatedFiles=maxRotatedFiles)
    application.setComponent(ILogObserver, FileLogObserver(logfile).emit)

    buildmaster_host = '${cfg.masterhost}'
    # TODO: masterport?
    port = 9989
    slavename = '${cfg.username}'
    passwd = '${cfg.password}'
    keepalive = 600
    usepty = 0
    umask = None
    maxdelay = 300
    allow_shutdown = None

    ${cfg.extraConfig}

    s = BuildSlave(buildmaster_host, port, slavename, passwd, basedir,
                  keepalive, usepty, umask=umask, maxdelay=maxdelay,
                  allow_shutdown=allow_shutdown)
    s.setServiceParent(application)
    '';

  cfg = config.makefu.buildbot.slave;

  api = {
    enable = mkEnableOption "Buildbot Slave";

    workDir = mkOption {
      default = "/var/lib/buildbot/slave";
      type = types.str;
      description = ''
        Path to build bot slave directory.
        Will be created on startup.
      '';
    };

    masterhost = mkOption {
      default = "localhost";
      type = types.str;
      description = ''
        Hostname/IP of the buildbot master
      '';
    };

    username = mkOption {
      type = types.str;
      description = ''
        slavename used to authenticate with master
      '';
    };

    password = mkOption {
      type = types.str;
      description = ''
        slave password used to authenticate with master
      '';
    };

    contact = mkOption {
      default = "nix slave <buildslave@${config.networking.hostName}>";
      type = types.str;
      description = ''
        contact to be announced by buildslave
      '';
    };

    description = mkOption {
      default = "Nix Generated BuildSlave";
      type = types.str;
      description = ''
        description for hostto be announced by buildslave
      '';
    };

    extraConfig = mkOption {
      default = "";
      type = types.lines;
      example = ''
        port = 443
        keepalive = 600
      '';
      description = ''
        extra config evaluated before calling BuildSlave init in .tac file
      '';
    };
  };

  imp = {

    users.extraUsers.buildbotSlave = {
      uid = 1408105834; #genid buildbotMaster
      description = "Buildbot Slave";
      home = cfg.workDir;
      createHome = false;
    };

    users.extraGroups.buildbotSlave = {
      gid = 1408105834;
    };

    systemd.services."buildbotSlave-${cfg.username}-${cfg.masterhost}" = {
      description = "Buildbot Slave for ${cfg.username}@${cfg.masterhost}";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = let
        workdir = "${lib.shell.escape cfg.workDir}";
        contact = "${lib.shell.escape cfg.contact}";
        description = "${lib.shell.escape cfg.description}";
        buildbot = pkgs.buildbot-slave;
        # TODO:make this
      in {
        PermissionsStartOnly = true;
        Type = "forking";
        PIDFile = "${workdir}/twistd.pid";
        # TODO: maybe also prepare buildbot.tac?
        ExecStartPre = pkgs.writeScript "buildbot-master-init" ''
          #!/bin/sh
          set -efux
          mkdir -p ${workdir}/info
          cp ${buildbot-slave-init} ${workdir}/buildbot.tac
          echo ${contact} > ${workdir}/info/admin
          echo ${description} > ${workdir}/info/host

          chown buildbotSlave:buildbotSlave -R ${workdir}
          chmod 700 -R ${workdir}
        '';
        ExecStart = "${buildbot}/bin/buildslave start ${workdir}";
        ExecStop = "${buildbot}/bin/buildslave stop ${workdir}";
        PrivateTmp = "true";
        User = "buildbotSlave";
        Restart = "always";
        RestartSec = "10";
      };
    };
  };
in
{
  options.makefu.buildbot.slave = api;
  config = mkIf cfg.enable imp;
}
