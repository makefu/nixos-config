{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
let
  sec = toString <secrets>;
  ext-dom = "wiki.euer.krebsco.de";

  user = config.services.nginx.user;
  group = config.services.nginx.group;
  fpm-socket = "/var/run/php5-fpm.sock";
  hostname = config.krebs.build.host.name;
  tw-upload = pkgs.tw-upload-plugin;
  base-dir = "/var/www/wiki.euer";
  base-cfg = "${base-dir}/twconf.ini";
  wiki-dir = "${base-dir}/store/";
  backup-dir = "${base-dir}/backup/";
  # contains:
  #  user1 = pass1
  #  userN = passN
  # afterwards put /var/www/<ext-dom>/user1.html as tiddlywiki
  tw-pass-file = "${sec}/tw-pass.ini";

in {
  state = [ base-dir ];
  # hotfix for broken wiki after reboot
  systemd.services."phpfpm-euer-wiki".serviceConfig.RequiresMountFor = [ "/media/cloud" ];
  services.phpfpm = {
    pools.euer-wiki = {
      inherit user group;
      listen = fpm-socket;
      settings = {
        "listen.owner" = user;
        "pm" = "dynamic";
        "pm.max_children" = 5;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 1;
        "pm.max_spare_servers" = 3;
        "chdir" = "/";
        "php_admin_value[error_log]" = "stderr";
        "php_admin_flag[log_errors]" = "on";
        "catch_workers_output" = "yes";

      };
      phpEnv.twconf = base-cfg;
    };
  };

  systemd.services.prepare-tw = {
    wantedBy = [ "local-fs.target" ];
    before = [ "phpfpm.service" "nginx.service" ];
    serviceConfig = {
      ExecStart = pkgs.writeScript "prepare-tw-service" ''
        #!/bin/sh
        if ! test -d "${base-dir}" ;then
          mkdir -p "${wiki-dir}" "${backup-dir}"

          # write the base configuration
          cat > "${base-cfg}" <<EOF
        [users]
        $(cat "${tw-pass-file}")
        [directories]
        backupdir = ${backup-dir}
        savedir = ${wiki-dir}
        EOF

          chown -R ${user}:${group} "${base-dir}"
          chmod 700  -R "${base-dir}"
        fi
      '';
      Type = "oneshot";
      RemainAfterExit = "yes";
      TimeoutSec = "0";
    };
  };

  services.nginx = {
    enable = mkDefault true;
    recommendedGzipSettings = true;
    virtualHosts = {
      "${ext-dom}" = {
        #serverAliases = [
        #  "wiki.makefu.r"
        #  "wiki.makefu"
        #];
        forceSSL = true;
        enableACME = true;
        locations = {
          "/" = {
            root = wiki-dir;
            index = "makefu.html";
            extraConfig = ''
              expires -1;
              autoindex on;
            '';
          };
          "/store.php" = {
            root = tw-upload;
            extraConfig = ''
              client_max_body_size 200M;
              fastcgi_split_path_info ^(.+\.php)(/.+)$;
              fastcgi_pass unix:${fpm-socket};
              include ${pkgs.nginx}/conf/fastcgi_params;
              include ${pkgs.nginx}/conf/fastcgi.conf;
            '';
          };
        };
      };
    };
  };
}
