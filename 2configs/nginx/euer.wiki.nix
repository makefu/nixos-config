{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
let
  sec = toString <secrets>;
  ext-dom = "wiki.euer.krebsco.de";
  acmepath = "/var/lib/acme/";
  acmechall = acmepath + "/challenges/";

  #ssl_cert = "${sec}/wildcard.krebsco.de.crt";
  #ssl_key  = "${sec}/wildcard.krebsco.de.key";
  ssl_cert = "${acmepath}/${ext-dom}/fullchain.pem";
  ssl_key = "${acmepath}/${ext-dom}/key.pem";

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
  tw-pass-file = "${sec}/tw-pass.ini";
  external-ip = config.krebs.build.host.nets.internet.ip4.addr;
  internal-ip = config.krebs.build.host.nets.retiolum.ip4.addr;
in {
  services.phpfpm = {
    # phpfpm does not have an enable option
    poolConfigs  = {
      euer-wiki = ''
        user =  ${user}
        group =  ${group}
        listen = ${fpm-socket}
        listen.owner = ${user}
        listen.group = ${group}
        env[twconf] = ${base-cfg};
        pm = dynamic
        pm.max_children = 5
        pm.start_servers = 2
        pm.min_spare_servers = 1
        pm.max_spare_servers = 3
        chdir = /
        php_admin_value[error_log] = 'stderr'
        php_admin_flag[log_errors] = on
        catch_workers_output = yes
      '';
    };
  };

  systemd.services.prepare-tw = {
    wantedBy = [ "local-fs.target" ];
    before = [ "phpfpm.service" ];
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

  krebs.nginx = {
    enable = mkDefault true;
    servers = {
      euer-wiki = {
        listen = [ "${external-ip}:80" "${external-ip}:443 ssl"
                   "${internal-ip}:80" "${internal-ip}:443 ssl" ];
        server-names = [
          ext-dom
          "wiki.makefu.retiolum"
          "wiki.makefu"
        ];
        ssl = {
          enable = true;
          # these certs will be needed if acme has not yet created certificates:
          certificate =   ssl_cert;
          certificate_key = ssl_key;
          force_encryption = true;
        };
        extraConfig = ''
          gzip on;
          gzip_buffers 4 32k;
          gzip_types  text/plain application/x-javascript text/css;
          default_type text/plain;

        '';
        locations = [
          (nameValuePair "/" ''
            root ${wiki-dir};
            expires -1;
            autoindex on;
          '')
          (nameValuePair "/store.php" ''
            root ${tw-upload};
            client_max_body_size 200M;
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass unix:${fpm-socket};
            include ${pkgs.nginx}/conf/fastcgi_params;
            include ${pkgs.nginx}/conf/fastcgi.conf;
          '')
          (nameValuePair  "/.well-known/acme-challenge" ''
            root ${acmechall}/${ext-dom}/;
          '')

        ];
      };
    };
  };
  security.acme.certs."${ext-dom}" = {
    email = "acme@syntax-fehler.de";
    webroot = "${acmechall}/${ext-dom}/";
    group = "nginx";
    allowKeysForGroup = true;
    postRun = "systemctl reload nginx.service";
    extraDomains."${ext-dom}" = null ;
  };
}
