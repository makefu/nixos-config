{ config, lib, pkgs, ... }:

with lib;
let
  sec = toString <secrets>;
  ssl_cert = "${sec}/wildcard.krebsco.de.crt";
  ssl_key  = "${sec}/wildcard.krebsco.de.key";
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
  external-ip = head config.krebs.build.host.nets.internet.addrs4;
  internal-ip = head config.krebs.build.host.nets.retiolum.addrs4;
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
        # errors to journal
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
          "wiki.euer.krebsco.de"
          "wiki.makefu.retiolum"
          "wiki.makefu"
        ];
        extraConfig = ''
          gzip on;
          gzip_buffers 4 32k;
          gzip_types  text/plain application/x-javascript text/css;
          ssl_certificate ${ssl_cert};
          ssl_certificate_key ${ssl_key};
          default_type text/plain;

          if ($scheme = http){
            return 301 https://$server_name$request_uri;
          }

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
        ];
      };
    };
  };
}
