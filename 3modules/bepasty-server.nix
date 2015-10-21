{ config, lib, pkgs, ... }:

with lib;
let
  gunicorn = pkgs.pythonPackages.gunicorn;
  bepasty = pkgs.pythonPackages.bepasty-server;
  gevent = pkgs.pythonPackages.gevent;
  python = pkgs.pythonPackages.python;
  cfg = config.makefu.bepasty-server;

  out = {
    options.makefu.bepasty-server = api;
    config = mkIf cfg.enable (mkMerge [(mkIf cfg.serveNginx nginx-imp) imp ]) ;
  };

  api = {
    enable = mkEnableOption "Bepasty Servers";
    serveNginx = mkEnableOption "Serve Bepasty Servers with Nginx";

    servers = mkOption {
      type = with types; attrsOf optionSet;
      options = singleton {
        nginxCfg = mkOption {
          # TODO use the correct type
          type = with types; attrsOf unspecified;
          description = ''
            additional nginx configuration. see krebs.nginx for all options
          '' ;
        };
        debug = mkOption {
          type = types.bool;
          description = ''
            run server in debug mode
          '';
          default = false;
        };

        # TODO: assert secretKey
        secretKey = mkOption {
          type = types.str;
          description = ''
            server secret for safe session cookies, must be set.
          '';
        };

        # we create a wsgi socket in $workDir/gunicorn-${name}.wsgi
        workDir = mkOption {
          type = types.str;
          description = ''
            Path to the working directory (used for sockets and pidfile).
            Defaults to the users home directory. Must be accessible to nginx,
            permissions will be set to 755
          '';
          default = config.users.extraUsers.bepasty.home;
        };

        dataDir = mkOption {
          type = types.str;
          description = ''
            Defaults to the new users home dir which defaults to
            /var/lib/bepasty-server/data
            '';
          default = "${config.users.extraUsers.bepasty.home}/data";
        };

        extraConfig = mkOption {
          type = types.str;
          default = "";
          example = ''
            PERMISSIONS = {
              'myadminsecret': 'admin,list,create,read,delete',
            }
            MAX_ALLOWED_FILE_SIZE = 5 * 1000 * 1000
            '';
        };

        defaultPermissions = mkOption {
          type = types.str;
          default = "list";
        };

      };
      default = {};
    };

  };

  imp = {
    # Configures systemd services for each configured server
    # environment.systemPackages = [ bepasty gunicorn gevent ];
    systemd.services = mapAttrs' (name: server:
      nameValuePair ("bepasty-server-${name}")
        ({
          description = "Bepasty Server ${name}";
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];
          restartIfChanged = true;
          environment = {
            BEPASTY_CONFIG = "${server.workDir}/bepasty-${name}.conf";
            PYTHONPATH= "${bepasty}/lib/${python.libPrefix}/site-packages:${gevent}/lib/${python.libPrefix}/site-packages";
          };
          serviceConfig = {
            Type = "simple";
            PrivateTmp = true;
            ExecStartPre = pkgs.writeScript "bepasty-server.${name}-init" ''
              #!/bin/sh
              chmod 755 "${server.workDir}"
              mkdir -p "${server.dataDir}"
              cat > ${server.workDir}/bepasty-${name}.conf <<EOF
              SITENAME="${name}"
              STORAGE_FILESYSTEM_DIRECTORY="${server.dataDir}"
              SECRET_KEY="${escape server.secretKey}"
              DEFAULT_PERMISSIONS="${server.defaultPermissions}"
              ${server.extraConfig}
              EOF
            '';
            Directory = "${bepasty}/lib/${python.libPrefix}/site-packages";
            # we use Gunicorn to start a wsgi server
            ExecStart = ''${gunicorn}/bin/gunicorn bepasty.wsgi --name ${name} \
              --workers 3 --log-level=info \
              --bind=unix:${server.workDir}/gunicorn-${name}.sock \
              --pid ${server.workDir}/gunicorn-${name}.pid \
              -k gevent
            '';
          };
        })
    ) cfg.servers;

    users.extraUsers.bepasty = {
      uid = 2796546855; #genid bepasty
      home = "/var/lib/bepasty-server";
      createHome = true;
    };
  };
  nginx-imp = {
    assertions = [ { assertion = config.krebs.nginx.enable;
                      message = "krebs.nginx.enable must be true"; }];

    krebs.nginx.servers = mapAttrs' (name: server:
      nameValuePair("bepasty-server-${name}")
      (server.nginxCfg // {
        extraConfig = ''
          client_max_body_size 32M;
          '';
        locations = [
          (nameValuePair ("/")
          (''
            proxy_set_header Host $http_host;
            proxy_pass http://unix:${server.workDir}/gunicorn-${name}.sock;
          ''))
          (nameValuePair ("/static/")
          (''
            alias ${bepasty}/lib/${python.libPrefix}/site-packages/bepasty/static/;
          ''))
          ];
      })
    ) cfg.servers ;
  };
in
out
