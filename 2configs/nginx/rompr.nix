{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
let
  user = config.services.nginx.user;
  group = config.services.nginx.group;
  src = pkgs.fetchFromGitHub {
    owner = "fatg3erman";
    repo = "RompR";
    rev = "1.21";
    sha256 = "00gk2c610qgpsb6y296h9pz2aaa6gfq4cqhn15l7fdrk3lkvh01q";
  };
  fpm-socket = "/var/run/php5-rompr-fpm.sock";
  mpd-src = "/var/lib/rompr";

in {
  services.phpfpm = {
    # phpfpm does not have an enable option
    poolConfigs  = {
      mpd = ''
        user =  ${user}
        group =  ${group}
        listen = ${fpm-socket}
        listen.owner = ${user}
        listen.group = ${group}
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
  # TODO: Pre-job
  # TODO: prefs.var could be templated (serialized php ...) then we would not
  # need to have a state dir at all
  system.activationScripts.rompr = ''
    mkdir -p ${mpd-src}
    cp -r ${src}/. ${mpd-src}
    chown -R ${user}:${group} ${mpd-src}
    chmod 770 ${mpd-src}
  '';
  services.nginx = {
    enable = mkDefault true;
    virtualHosts = {
      "localhost" = {
        root = mpd-src;
        locations."/".index = "index.php";
        locations."~ \.php$" = {
          root = mpd-src;
          extraConfig = ''
            client_max_body_size 200M;
            fastcgi_pass unix:${fpm-socket};
            include ${pkgs.nginx}/conf/fastcgi_params;
            include ${pkgs.nginx}/conf/fastcgi.conf;
            fastcgi_index  index.php;
            try_files $uri =404;
          '';
        };
      };
    };
  };
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    ensureDatabases = [ "romprdb" ];
    ensureUsers = [
      { ensurePermissions = { "romprdb.*" = "ALL PRIVILEGES"; };
        name = user; }
    ];
  };
}
