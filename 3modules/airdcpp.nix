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
    extraGroups = mkOption {
      description = ''extra groups for the user (only for default user)'';
      type = listOf str;
      default = [];
      example = [ "nginx" ];
    };

    stateDir = mkOption {
      description = ''
        directory for storing state (pid,config)
      '';
      type = str;
      default = "/var/lib/airdcpp";
    };
    dcpp = {
      Nick = mkOption {
        description = ''
          Nick Name for connection
        '';
        type = str;
        default = "kevin";
      };
      InPort = mkOption {
        description = "Input Port";
        type = int;
        default = 16849;
      };
      UDPPort = mkOption {
        description = "UDP open Port";
        type = int;
        default = 16849;
      };
      TLSPort = mkOption {
        description = "TLS open Port";
        type = int;
        default = 16869;
      };
      DownloadSpeed = mkOption {
        description = "Total Download Speed in Mbps/s";
        type = str;
        default = "100";
      };
      UploadSpeed = mkOption {
        description = "Total Upload Speed in Mbp/s";
        type = str;
        default = "100";
      };
      shares = mkOption {
        default = {};
        type = attrsOf (submodule ( { config, ... }: {
          options = {
            path = mkOption {
              description = "path to the share";
              type = str;
            };
            incoming = mkOption {
              description = "incoming";
              type = bool;
              default = false;
            };
          };
        }));
      };
      initialConfigFile = mkOption {
        description = ''
          path inital DCPlusPlus.xml configuration if none exists
        '';
        type = nullOr path;
        default = null;
      };
    };
    web = {
      port = mkOption {
        description = ''web-ui port

        NOTE: once the initial config had been written to the state directory it will not be replaced
        '';
        type = int;
        default = 5600;
      };
      initialConfigFile = mkOption {
        description = ''
          path inital WebServer.xml configuration if none exists
        '';
        type = nullOr path;
        default = null;
      };
      # TODO: tlsPort
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
  };

  imp = let
    genUsers = users: concatMapStringsSep "\n" (user: 
      ''<WebUser Username="${user.name}" Password="${user.password}" LastLogin="0" Permissions="${user.permissions}"/>'' )
      (mapAttrsToList (name: val: val // { inherit name; }) users);
    genShares = shares: concatMapStringsSep "\n" (share:
      ''<Directory Virtual="stockholm" Incoming="${
          if share.incoming then "1" else "0"
        }" LastRefreshTime="0">${share.path}</Directory>'' )
      (mapAttrsToList (name: val: val // { inherit name; }) shares);
    webConfigFile = if (cfg.web.initialConfigFile == null) then builtins.trace "warning: airdcpp passwords are stored in plain text" pkgs.writeText "initial-config" ''
      <?xml version="1.0" encoding="utf-8" standalone="yes"?>
      <WebServer>
        <Config>
          <Server Port="${toString cfg.web.port}"/>
          <TLSServer Port="0" Certificate="" CertificateKey=""/>
        </Config>
        <WebUsers>${genUsers cfg.web.users}
        </WebUsers>
      </WebServer>
      '' else cfg.web.initialConfigFile;
    dcppConfigFile = if (cfg.dcpp.initialConfigFile == null) then pkgs.writeText "initial-config" ''
    <?xml version="1.0" encoding="utf-8" standalone="yes"?>
    <DCPlusPlus>
      <Settings>
        <Nick type="string">${cfg.dcpp.Nick}</Nick>
        <ConfigVersion type="string">${cfg.package.version}</ConfigVersion>
        <InPort type="int">${toString cfg.dcpp.InPort}</InPort>
        <UDPPort type="int">${toString cfg.dcpp.UDPPort}</UDPPort>
        <TLSPort type="int">${toString cfg.dcpp.TLSPort}</TLSPort>
        <ConfigBuildNumber type="int">0</ConfigBuildNumber>
        <AutoDetectIncomingConnection type="int">0</AutoDetectIncomingConnection>
        <NoIpOverride type="int">1</NoIpOverride>
        <WizardRunNew type="int">0</WizardRunNew>
        <IPUpdate type="int">0</IPUpdate>
        <AlwaysCCPM type="int">1</AlwaysCCPM>
        <DownloadSpeed type="string">${cfg.dcpp.DownloadSpeed}</DownloadSpeed>
        <UploadSpeed type="string">${cfg.dcpp.UploadSpeed}</UploadSpeed>
      </Settings>
      <Share Token="0" Name="Default">
        ${genShares cfg.dcpp.shares}
        <NoShare/>
      </Share>
      <ChatFilterItems/>
    </DCPlusPlus>
    '' else cfg.dcpp.initialConfigFile;
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
          test -e $d || install -m700 -o${cfg.user} ${webConfigFile} $d
          d=${cfg.stateDir}/DCPlusPlus.xml
          test -e $d || install -m700 -o${cfg.user} ${dcppConfigFile} $d
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
        inherit (cfg) extraGroups;
      };
      groups.airdcpp.gid = genid "airdcpp";
    };
  };
in
out

