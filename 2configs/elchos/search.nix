{ config, lib, pkgs, ... }:

# search also generates ddclient entries for all other logs

with import <stockholm/lib>;
let
  #primary-itf = "eth0";
  #primary-itf = "wlp2s0";
  primary-itf = config.makefu.server.primary-itf;
  elch-sock = "${config.services.uwsgi.runDir}/uwsgi-elch.sock";
  ddclientUser = "ddclient";
  sec = toString <secrets>;
  nsupdate = import "${sec}/nsupdate-search.nix";
  stateDir = "/var/spool/ddclient";
  cfg = "${stateDir}/cfg";
  ddclientPIDFile = "${stateDir}/ddclient.pid";

  # TODO: correct cert generation requires a `real` internet ip address

  gen-cfg = dict: ''
    ssl=yes
    cache=${stateDir}/ddclient.cache
    pid=${ddclientPIDFile}
    ${concatStringsSep "\n" (mapAttrsToList (user: pass: ''

      protocol=dyndns2
      use=if, if=${primary-itf}
      ssl=yes
      server=ipv4.nsupdate.info
      login=${user}
      password='${pass}'
      ${user}

      protocol=dyndns2
      usev5=if, if=${primary-itf}
      ssl=yes
      server=ipv6.nsupdate.info
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
  services.redis.enable = mkForce true;
  services.redis.bind = "127.0.0.1";

  services.uwsgi = {
    enable = true;
    user = "nginx";
    plugins = [ "python3" ];
    instance = {
      type = "emperor";
      vassals = {
        elchhub = {
          type = "normal";
          pythonPackages = self: with self; [ pkgs.elchhub ];
          socket = elch-sock;
        };
      };
    };
  };

  services.nginx = {
    enable = mkDefault true;
    virtualHosts = {
      "search.nsupdate.info" = {
        enableACME = true;
        forceSSL = true;
        locations = {
          "/".extraConfig = ''
            uwsgi_pass unix://${elch-sock};
            uwsgi_param         UWSGI_CHDIR     ${pkgs.elchhub}/${pkgs.python3.sitePackages};
            uwsgi_param         UWSGI_MODULE    elchhub.wsgi;
            uwsgi_param         UWSGI_CALLABLE  app;

            include ${pkgs.nginx}/conf/uwsgi_params;
          '';
        };
      };
    };
  };

  systemd.services = {
    redis.serviceConfig.LimitNOFILE=10032;
    elchos-ftp-scanner = {
      wantedBy = [ "multi-user.target" ];
      after = [ "ip-up.target" ];
      serviceConfig = {
        User = "nginx";
        ExecStart = "${pkgs.elchhub}/bin/elch-manager";
      };
    };
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

  networking.firewall = {
    allowedTCPPorts = [ 80 443 ];
    allowedUDPPorts = [ ];
  };
}
