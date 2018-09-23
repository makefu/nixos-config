{ config, lib, pkgs, ... }:
with import <stockholm/lib>; #genid
let
  cfg = config.makefu.airdcpp;

  out = {
    options.makefu.airdcpp = api;
    config = lib.mkIf cfg.enable imp;
  };

  api = with types;{
    enable = mkEnableOption "airdcpp";

    package = mkOption {
      type = package;
      default = pkgs.airdcpp-webclient;
    };

    user = mkOption {
      description = ''
        user which will run udpt. if kept default a new user will be created
      '';
      type = str;
      default = "airdcpp";
    };

    stateDir = mkOption {
      description = ''
        directory for storing state (pid,config)
      '';
      type = str;
      default = "/var/lib/airdcpp";
    };
    web = mkOption {
      type = submodule ( { config, ... }: {
        options = {
          port = mkOption {
            description = ''web-ui port

            NOTE: once the initial config had been written to the state directory it will not be replaced
            '';
            type = int;
            default = 5600;
          };
          # TODO: tlsPort
          # TODO: at least one user
          users = mkOption {
            type = attrsOf (submodule ( { config, ... }: {
              options = {
                password = mkOption {
                  description = "password of user";
                  type = str;
                };
                permissions = mkOption {
                  description = "user permissions";
                  type = str;
                  default = "admin";
                };
              };
            }));
          };
        };
      });
    };
    initialConfigFile = mkOption {
      description = ''
        path inital configuration if none exists
      '';
      type = nullOr path;
      default = null;
    };
  };

  imp = let
    genUsers = users: concatMapStringsSep "\n" (user: ''<WebUser Username="${user.name}" Password="${user.password}" LastLogin="0" Permissions="${user.permissions}"/>'' )
      (mapAttrsToList (name: val: val // { inherit name; }) users);
    configFile = if (cfg.initialConfigFile == null) then builtins.trace "warning: airdcpp passwords are stored in plain text" pkgs.writeText "initial-config" ''
      <?xml version="1.0" encoding="utf-8" standalone="yes"?>
      <WebServer>
        <Config>
          <Server Port="${toString cfg.web.port}"/>
          <TLSServer Port="0" Certificate="" CertificateKey=""/>
        </Config>
        <WebUsers>${genUsers cfg.web.users}
        </WebUsers>
      </WebServer>
      '' else cfg.initialConfigFile;
  in {
    systemd.services.airdcpp = {
      description = "airdcpp webui";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      restartIfChanged = true;
      serviceConfig = {
        Type = "simple";
        ExecStartPre = pkgs.writeDash "prepare-env" ''
          d=${cfg.stateDir}/WebServer.xml
          test -e $d || install -m700 -o${cfg.user} ${configFile} $d
        '';
        PermissionsStartOnly = true;
        ExecStart = "${cfg.package}/bin/airdcppd -c=${cfg.stateDir} -p=${cfg.stateDir}/airdcpp.pid";
        PrivateTmp = true;
        WorkingDirectory = cfg.stateDir;
        User = "${cfg.user}";
      };
    };
    users = lib.mkIf (cfg.user == "airdcpp") {
      users.airdcpp = {
        uid = genid "airdcpp";
        home = cfg.stateDir;
        createHome = true;
      };
      groups.airdcpp.gid = genid "airdcpp";
    };
  };
in
out

