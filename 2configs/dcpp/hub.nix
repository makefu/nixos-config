{ config, lib, pkgs, ... }:

# search also generates ddclient entries for all other logs

with import <stockholm/lib>;
let
  ddclientUser = "ddclient";
  sec = toString <secrets>;
  nsupdate = import "${sec}/nsupdate-hub.nix";
  stateDir = "/var/spool/ddclient";
  cfg = "${stateDir}/cfg";
  ext-if = config.makefu.server.primary-itf;
  ddclientPIDFile = "${stateDir}/ddclient.pid";

  # TODO: correct cert generation requires a `real` internet ip address

  gen-cfg = dict: ''
    ssl=yes
    cache=${stateDir}/ddclient.cache
    pid=${ddclientPIDFile}
    ${concatStringsSep "\n" (mapAttrsToList (user: pass: ''

      protocol=dyndns2
      use=web, web=http://ipv4.nsupdate.info/myip
      ssl=yes
      server=ipv4.nsupdate.info
      login=${user}
      password='${pass}'
      ${user}

    '') dict)}
  '';

in {
  users.extraUsers = singleton {
    name = ddclientUser;
    uid = genid "ddclient";
    description = "ddclient daemon user";
    home = stateDir;
    createHome = true;
  };

  systemd.services = {
    redis.serviceConfig.LimitNOFILE=10032;
    ddclient-nsupdate-uhub = {
      wantedBy = [ "multi-user.target" ];
      after = [ "ip-up.target" ];
      serviceConfig = {
        Type = "forking";
        User = ddclientUser;
        PIDFile = ddclientPIDFile;
        ExecStartPre = pkgs.writeDash "init-nsupdate" ''
          cp -vf ${pkgs.writeText "ddclient-config" (gen-cfg nsupdate)} ${cfg}
          chmod 700 ${cfg}
        '';
        ExecStart = "${pkgs.ddclient}/bin/ddclient -verbose -daemon 1 -noquiet -file ${cfg}";
      };
    };
  };

  networking.firewall.extraCommands = ''
    iptables -A PREROUTING -t nat -i ${ext-if} -p tcp --dport 411 -j REDIRECT --to-port 1511
  '';
  systemd.services.uhub.serviceConfig = {
    PrivateTmp = true;
    PermissionsStartOnly = true;
    ExecStartPre = pkgs.writeDash "uhub-pre" ''
      cp ${toString <secrets/wildcard.krebsco.de.crt>} /tmp/uhub.crt
      cp ${toString <secrets/wildcard.krebsco.de.key>} /tmp/uhub.key
      cp ${toString <secrets/uhub.sql>} /tmp/uhub.sql
      chown uhub /tmp/*
    '';

  };
  services.uhub = {
    enable = true;
    port = 1511;
    enableTLS = true;
    hubConfig = ''
      hub_name = "krebshub"
      tls_certificate = /tmp/uhub.crt
      tls_private_key = /tmp/uhub.key
      registered_users_only  = true
    '';
    plugins = {
      welcome = {
        enable = true;
        motd = "shareit";
        rules = "1. Don't be an asshole";
      };
      history = {
        enable = true;
      };
      authSqlite = {
        enable = true;
        file = "/tmp/uhub.sql";
      };

    };
  };
  networking.firewall.allowedTCPPorts = [ 411 1511 ];
}
