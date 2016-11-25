{ config, lib, pkgs, ... }:

# graphite-web on port 8080
# carbon cache on port 2003 (tcp/udp)
with import <stockholm/lib>;
let
  #primary-itf = "eth0";
  primary-itf = "wlp2s0";
  elch-sock = "${config.services.uwsgi.runDir}/uwsgi-elch.sock";
  ddclientUser = "ddclient";
  sec = toString <secrets>;
  nsupdate = import "${sec}/nsupdate-search.nix";
  stateDir = "/var/spool/ddclient";
  cfg = "${stateDir}/cfg";
  ddclientPIDFile = "${stateDir}/ddclient.pid";

  acmepath = "/var/lib/acme/";
  acmechall = acmepath + "/challenges/";
  # TODO: correct cert generation requires a `real` internet ip address
  stats-dom = "stats.nsupdate.info";
  search-dom = "search.nsupdate.info";
  search_ssl_cert = "${acmepath}/${search-dom}/fullchain.pem";
  search_ssl_key = "${acmepath}/${search-dom}/key.pem";
  stats_ssl_cert = "${acmepath}/${stats-dom}/fullchain.pem";
  stats_ssl_key = "${acmepath}/${stats-dom}/key.pem";

  gen-cfg = dict: ''
    ssl=yes
    cache=${stateDir}/ddclient.cache
    pid=${ddclientPIDFile}
    ${concatStringsSep "\n" (mapAttrsToList (user: pass: ''

      use=if, if=${primary-itf}
      protocol=dyndns2, server=ipv4.nsupdate.info, login=${user}, password='${pass}' ${user}
      #usev6=if, if=${primary-itf}
      #protocol=dyndns2, server=ipv6.nsupdate.info, login=${user}, password='${pass}' ${user}
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

  security.acme.certs = {
    "${stats-dom}" = {
      email = "acme@syntax-fehler.de";
      webroot = "${acmechall}/${stats-dom}/";
      group = "nginx";
      allowKeysForGroup = true;
      postRun = "systemctl reload nginx.service";
      extraDomains = {
        "${stats-dom}" = null ;
      };
    };
    "${search-dom}" = {
      email = "acme@syntax-fehler.de";
      webroot = "${acmechall}/${search-dom}/";
      group = "nginx";
      allowKeysForGroup = true;
      postRun = "systemctl reload nginx.service";
      extraDomains = {
        "${stats-dom}" = null ;
      };
    };
  };

  krebs.nginx = {
    enable = mkDefault true;
    servers = {
      elch-stats = {
        server-names = [ stats-dom ];
        # listen = [ "80" "443 ssl" ];
        ssl = {
            enable = true;
            certificate =   stats_ssl_cert;
            certificate_key = stats_ssl_key;
            force_encryption = true;
        };

        locations = [
            (nameValuePair "/" ''
              proxy_set_header   Host $host;
              proxy_set_header   X-Real-IP          $remote_addr;
              proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_pass http://localhost:3000/;
            '')
            (nameValuePair  "/.well-known/acme-challenge" ''
             root ${acmechall}/${search-dom}/;
            '')
        ];
      };
      elchhub = {
        server-names = [ "search.nsupdate.info" ];
        # listen = [ "80" "443 ssl" ];
        ssl = {
            enable = true;
            certificate =   search_ssl_cert;
            certificate_key = search_ssl_key;
            force_encryption = true;
        };
        locations = [ (nameValuePair "/" ''
          uwsgi_pass unix://${elch-sock};
          uwsgi_param         UWSGI_CHDIR     ${pkgs.elchhub}/${pkgs.python3.sitePackages};
          uwsgi_param         UWSGI_MODULE    elchhub.wsgi;
          uwsgi_param         UWSGI_CALLABLE  app;

          include ${pkgs.nginx}/conf/uwsgi_params;
        '')
        (nameValuePair  "/.well-known/acme-challenge" ''
          root ${acmechall}/${search-dom}/;
        '')
        ];
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
    register-elchos-nsupdate = {
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

  services.grafana = {
    enable = true;
    addr = "127.0.0.1";
    users.allowSignUp = false;
    users.allowOrgCreate = false;
    users.autoAssignOrg = false;
    auth.anonymous.enable = true;
    security = import <secrets/grafana_security.nix>; # { AdminUser = ""; adminPassword = ""}
  };

  services.graphite = {
    api = {
      enable = true;
      listenAddress = "127.0.0.1";
      port = 8080;
    };
    carbon = {
      enableCache = true;
      # save disk usage by restricting to 1 bulk update per second
      config = ''
        [cache]
        MAX_CACHE_SIZE = inf
        MAX_UPDATES_PER_SECOND = 1
        MAX_CREATES_PER_MINUTE = 500
        '';
      storageSchemas = ''
        [carbon]
        pattern = ^carbon\.
        retentions = 60:90d

        [elchos]
        patterhn = ^elchos\.
        retentions = 10s:30d,60s:3y

        [default]
        pattern = .*
        retentions = 30s:30d,300s:1y
        '';
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 2003 80 443 ];
    allowedUDPPorts = [ 2003 ];
  };
}
