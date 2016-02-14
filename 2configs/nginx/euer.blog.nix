{ config, lib, pkgs, ... }:

with config.krebs.lib;
let
  sec = toString <secrets>;
  ssl_cert = "${sec}/wildcard.krebsco.de.crt";
  ssl_key  = "${sec}/wildcard.krebsco.de.key";
  hostname = config.krebs.build.host.name;
  user = config.services.nginx.user;
  group = config.services.nginx.group;
  external-ip = head config.krebs.build.host.nets.internet.addrs4;
  internal-ip = head config.krebs.build.host.nets.retiolum.addrs4;
  base-dir = "/var/www/blog.euer";
in {
  # Prepare Blog directory
  systemd.services.prepare-euer-blog = {
    wantedBy = [ "local-fs.target" ];
    before = [ "nginx.service" ];
    serviceConfig = {
      # do nothing if the base dir already exists
      ExecStart = pkgs.writeScript "prepare-euer-blog-service" ''
        #!/bin/sh
        if ! test -d "${base-dir}" ;then
          mkdir -p "${base-dir}"
          chown ${user}:${group} "${base-dir}"
          chmod 700 "${base-dir}"
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
      euer-blog = {
        listen = [ "${external-ip}:80" "${external-ip}:443 ssl"
                   "${internal-ip}:80" "${internal-ip}:443 ssl" ];
        server-names = [ "euer.krebsco.de" "blog.euer.krebsco.de" "blog.${hostname}" ];
        extraConfig = ''
          gzip on;
          gzip_buffers 4 32k;
          gzip_types  text/plain application/x-javascript text/css;
          ssl_certificate ${ssl_cert};
          ssl_certificate_key ${ssl_key};
          default_type text/plain;
        '';
        locations = singleton (nameValuePair "/" ''
          root ${base-dir};
        '');
      };
    };
  };
}
