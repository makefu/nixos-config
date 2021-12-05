{ config, lib, pkgs, ... }:

# search also generates ddclient entries for all other logs

with import <stockholm/lib>;
let
  #primary-itf = "eth0";
  #primary-itf = "wlp2s0";
  primary-itf = config.makefu.server.primary-itf;
  ddclientUser = "ddclient";
  sec = toString <secrets>;
  nsupdate = import "${sec}/nsupdate-data.nix";
  stateDir = "/var/spool/ddclient";
  cfg = "${stateDir}/cfg";
  ddclientPIDFile = "${stateDir}/ddclient.pid";

  # TODO: correct cert generation requires a `real` internet ip address

  gen-cfg = dict: ''
    ssl=yes
    cache=${stateDir}/ddclient.cache
    pid=${ddclientPIDFile}
    ${concatStringsSep "\n" (mapAttrsToList (user: pass: ''

      use=if, if=${primary-itf} protocol=dyndns2, server=ipv4.nsupdate.info, login=${user}, password='${pass}' ${user}
      usev6=if, if=${primary-itf} protocol=dyndns2, server=ipv6.nsupdate.info, login=${user}, password='${pass}' ${user}
    '') dict)}
  '';

in {
  users.users.${ddclientUser} = {
    name = ddclientUser;
    uid = genid ddclientUser;
    description = "ddclient daemon user";
    home = stateDir;
    createHome = true;
    isSystemUser = true;
    group = ddclientUser;
  };
  users.groups.${ddclientUser} = {};

  systemd.services = {
    ddclient-nsupdate-elchos = {
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
}
