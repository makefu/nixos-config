{ config, pkgs, lib, ... }:

with lib;
let
  buildbot = pkgs.buildbot;
  buildbot-master-config = pkgs.writeText "buildbot-master.cfg" ''
    # -*- python -*-
    from buildbot.plugins import *

    c = BuildmasterConfig = {}

    c['slaves'] = []
    # TODO: template potential buildslaves
    # TODO: set password?
    slavenames= [ 'testslave' ]
    for i in slavenames:
      c['slaves'].append(buildslave.BuildSlave(i, "krebspass"))

    c['protocols'] = {'pb': {'port': 9989}}

    ####### Build Inputs
    stockholm_repo = 'http://cgit.gum/stockholm'
    c['change_source'] = []
    c['change_source'].append(changes.GitPoller(
            stockholm_repo,
            workdir='stockholm-poller', branch='master',
            project='stockholm',
            pollinterval=120))

    ####### Build Scheduler
    # TODO: configure scheduler
    c['schedulers'] = []

    # test the master real quick
    fast = schedulers.SingleBranchScheduler(
                                change_filter=util.ChangeFilter(branch="master"),
                                name="fast-master-test",
                                builderNames=["fast-tests"])

    force = schedulers.ForceScheduler(
                                name="force",
                                builderNames=["full-tests"])

    # files everyone depends on or are part of the share branch
    def shared_files(change):
      import re
      r =re.compile("^((krebs|share)/.*|Makefile|default.nix)")
      for file in change.files:
        if r.match(file):
          return True
      return False

    full = schedulers.SingleBranchScheduler(
                                change_filter=util.ChangeFilter(branch="master"),
                                fileIsImportant=shared_files,
                                name="full-master-test",
                                builderNames=["full-tests"])
    c['schedulers'] = [ fast, force, full ]
    ###### The actual build
    # couple of fast steps:
    f = util.BuildFactory()
    ## fetch repo
    grab_repo = steps.Git(repourl=stockholm_repo, mode='incremental')
    f.addStep(grab_repo)

    # the dependencies which are used by the test script
    deps = [ "gnumake", "jq" ]
    nixshell = ["nix-shell", "-p" ] + deps + [ "--run" ]
    def addShell(f,**kwargs):
      f.addStep(steps.ShellCommand(**kwargs))

    addShell(f,name="centos7-eval",env={"LOGNAME": "shared",
                  "get" : "krebs.deploy",
                  "filter" : "json"
                 },
             command=nixshell + ["make -s eval system=test-centos7"])

    addShell(f,name="wolf-eval",env={"LOGNAME": "shared",
                  "get" : "krebs.deploy",
                  "filter" : "json"
                 },
             command=nixshell + ["make -s eval system=wolf"])

    c['builders'] = []
    c['builders'].append(
        util.BuilderConfig(name="fast-tests",
          slavenames=slavenames,
          factory=f))

    # TODO slow build
    c['builders'].append(
        util.BuilderConfig(name="full-tests",
          slavenames=slavenames,
          factory=f))

    ####### Status of Builds
    c['status'] = []

    from buildbot.status import html
    from buildbot.status.web import authz, auth
    # TODO: configure if http is wanted
    authz_cfg=authz.Authz(
        # TODO: configure user/pw
        auth=auth.BasicAuth([("krebs","bob")]),
        gracefulShutdown = False,
        forceBuild = 'auth',
        forceAllBuilds = 'auth',
        pingBuilder = False,
        stopBuild = False,
        stopAllBuilds = False,
        cancelPendingBuild = False,
    )
    # TODO: configure nginx
    c['status'].append(html.WebStatus(http_port=8010, authz=authz_cfg))

    from buildbot.status import words
    ${optionalString (cfg.irc.enable) ''
      irc = words.IRC("${cfg.irc.server}", "krebsbuild",
                      # TODO: multiple channels
                      channels=["${cfg.irc.channel}"],
                      notify_events={
                        'success': 1,
                        'failure': 1,
                        'exception': 1,
                        'successToFailure': 1,
                        'failureToSuccess': 1,
                      }${optionalString cfg.irc.allowForce ",allowForce=True"})
      c['status'].append(irc)
      ''}

    ####### PROJECT IDENTITY
    c['title'] = "Stockholm"
    c['titleURL'] = "http://krebsco.de"

    #c['buildbotURL'] = "http://buildbot.krebsco.de/"
    # TODO: configure url
    c['buildbotURL'] = "http://vbob:8010/"

    ####### DB URL
    c['db'] = {
        'db_url' : "sqlite:///state.sqlite",
    }
    ${cfg.extraConfig}
    '';

  cfg = config.makefu.buildbot.master;

  api = {
    enable = mkEnableOption "Buildbot Master";
    workDir = mkOption {
      default = "/var/lib/buildbot/master";
      type = types.str;
      description = ''
        Path to build bot master directory.
        Will be created on startup.
      '';
    };
    irc = mkOption {
      default = {};
      type = types.submodule ({ config, ... }: {
        options = {
          enable = mkEnableOption "Buildbot Master IRC Status";
          channel = mkOption {
            default = "nix-buildbot-meetup";
            type = types.str;
            description = ''
              irc channel the bot should connect to
            '';
          };
          allowForce = mkOption {
            default = false;
            type = types.bool;
            description = ''
              Determines if builds can be forced via IRC
            '';
          };
          nick = mkOption {
            default = "nix-buildbot";
            type = types.str;
            description = ''
              nickname for IRC
            '';
          };
          server = mkOption {
            default = "irc.freenode.net";
            type = types.str;
            description = ''
              Buildbot Status IRC Server to connect to
            '';
          };
        };
      });
    };

    extraConfig = mkOption {
      default = "";
      type = types.lines;
      description = ''
        extra config appended to the generated master.cfg
      '';
    };
  };

  imp = {

    users.extraUsers.buildbotMaster = {
      uid = 672626386; #genid buildbotMaster
      description = "Buildbot Master";
      home = cfg.workDir;
      createHome = false;
    };

    users.extraGroups.buildbotMaster = {
      gid = 672626386;
    };

    systemd.services.buildbotMaster = {
      description = "Buildbot Master";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.git ];
      serviceConfig = let
        workdir="${lib.shell.escape cfg.workDir}";
        # TODO: check if git is the only dep
      in {
        PermissionsStartOnly = true;
        Type = "forking";
        PIDFile = "${workdir}/twistd.pid";
        # TODO: maybe also prepare buildbot.tac?
        ExecStartPre = pkgs.writeScript "buildbot-master-init" ''
          #!/bin/sh
          set -efux
          if [ ! -e ${workdir} ];then
            mkdir -p ${workdir}
            ${buildbot}/bin/buildbot create-master -r -l 10 -f ${workdir}
          fi
          # always override the master.cfg
          cp ${buildbot-master-config} ${workdir}/master.cfg
          # sanity
          ${buildbot}/bin/buildbot checkconfig ${workdir}

          # TODO: maybe upgrade? not sure about this
          #       normally we should write buildbot.tac by our own
          # ${buildbot}/bin/buildbot upgrade-master ${workdir}

          chmod 700 -R ${workdir}
          chown buildbotMaster:buildbotMaster -R ${workdir}
        '';
        ExecStart = "${buildbot}/bin/buildbot start ${workdir}";
        ExecStop = "${buildbot}/bin/buildbot stop ${workdir}";
        ExecReload = "${buildbot}/bin/buildbot reconfig ${workdir}";
        PrivateTmp = "true";
        User = "buildbotMaster";
        Restart = "always";
        RestartSec = "10";
      };
    };
  };
in
{
  options.makefu.buildbot.master = api;
  config = mkIf cfg.enable imp;
}
