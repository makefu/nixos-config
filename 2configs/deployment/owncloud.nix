{ lib, pkgs, config, ... }:
with lib;

let
  # TODO: copy-paste from lass/2/websites/util.nix
  serveCloud = domains:
    let
      domain = head domains;
      root = "/var/www/${domain}/";
      socket = "/var/run/${domain}-phpfpm.sock";
    in {
      system.activationScripts."prepare-nextcloud-${domain}" = ''
        if test ! -e ${root} ;then
          echo "copying latest ${pkgs.owncloud.name} release to ${root}"
          mkdir -p $(dirname "${root}")
          cp -r  ${pkgs.owncloud} "${root}"
          chown -R nginx:nginx "${root}"
          chmod 770 "${root}"
        fi
      '';
      services.nginx.virtualHosts."${domain}" = {
        forceSSL = true;
        enableACME = true;
        enableSSL = true;
        serverAliases = domains;
        extraConfig = ''

          # Add headers to serve security related headers
          add_header Strict-Transport-Security "max-age=15768000; includeSubDomains; preload;";
          add_header X-Content-Type-Options nosniff;
          add_header X-Frame-Options "SAMEORIGIN";
          add_header X-XSS-Protection "1; mode=block";
          add_header X-Robots-Tag none;
          add_header X-Download-Options noopen;
          add_header X-Permitted-Cross-Domain-Policies none;

          # Path to the root of your installation
          root ${root};
          # set max upload size
          client_max_body_size 10G;
          fastcgi_buffers 64 4K;
          fastcgi_read_timeout 120;

          # Disable gzip to avoid the removal of the ETag header
          gzip off;

          # Uncomment if your server is build with the ngx_pagespeed module
          # This module is currently not supported.
          #pagespeed off;

          index index.php;
          error_page 403 /core/templates/403.php;
          error_page 404 /core/templates/404.php;

          rewrite ^/.well-known/carddav /remote.php/carddav/ permanent;
          rewrite ^/.well-known/caldav /remote.php/caldav/ permanent;

          # The following 2 rules are only needed for the user_webfinger app.
          # Uncomment it if you're planning to use this app.
          rewrite ^/.well-known/host-meta /public.php?service=host-meta last;
          rewrite ^/.well-known/host-meta.json /public.php?service=host-meta-json last;
        '';
        locations."/robots.txt".extraConfig = ''
          allow all;
          log_not_found off;
          access_log off;
        '';
        locations."~ ^/(build|tests|config|lib|3rdparty|templates|data)/".extraConfig = ''
          deny all;
        '';

        locations."~ ^/(?:autotest|occ|issue|indie|db_|console)".extraConfig =  ''
          deny all;
        '';

        locations."/".extraConfig = ''
          rewrite ^/remote/(.*) /remote.php last;
          rewrite ^(/core/doc/[^\/]+/)$ $1/index.html;
          try_files $uri $uri/ =404;
        '';

        locations."~ \.php(?:$|/)".extraConfig =  ''
          fastcgi_split_path_info ^(.+\.php)(/.+)$;
          include ${pkgs.nginx}/conf/fastcgi_params;
          fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
          fastcgi_param PATH_INFO $fastcgi_path_info;
          fastcgi_param HTTPS on;
          fastcgi_param modHeadersAvailable true; #Avoid sending the security headers twice
          fastcgi_pass unix:${socket};
          fastcgi_intercept_errors on;
        '';

        # Adding the cache control header for js and css files
        # Make sure it is BELOW the location ~ \.php(?:$|/) block
        locations."~* \.(?:css|js)$".extraConfig = ''
          add_header Cache-Control "public, max-age=7200";
          # Add headers to serve security related headers
          add_header Strict-Transport-Security "max-age=15768000; includeSubDomains; preload;";
          add_header X-Content-Type-Options nosniff;
          add_header X-Frame-Options "SAMEORIGIN";
          add_header X-XSS-Protection "1; mode=block";
          add_header X-Robots-Tag none;
          # Optional: Don't log access to assets
          access_log off;
        '';
        # Optional: Don't log access to other assets
        locations."~* \.(?:jpg|jpeg|gif|bmp|ico|png|swf)$".extraConfig = ''
          access_log off;
        '';
      };
      services.phpfpm.poolConfigs."${domain}" = ''
        listen = ${socket}
        user = nginx
        group = nginx
        pm = dynamic
        pm.max_children = 32
        pm.max_requests = 500
        pm.start_servers = 2
        pm.min_spare_servers = 2
        pm.max_spare_servers = 5
        listen.owner = nginx
        listen.group = nginx
        php_admin_value[error_log] = 'stderr'
        php_admin_flag[log_errors] = on
        env[PATH] = ${lib.makeBinPath [ pkgs.php ]}
        catch_workers_output = yes
      '';
    };
in  {
  imports = [
    ( serveCloud [ "o.euer.krebsco.de" ] )
  ];

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    rootPassword = config.krebs.secret.files.mysql_rootPassword.path;
  };

  krebs.secret.files.mysql_rootPassword = {
    path = "${config.services.mysql.dataDir}/mysql_rootPassword";
    owner.name = "root";
    source-path = toString <secrets> + "/mysql_rootPassword";
  };
}
