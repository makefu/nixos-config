{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
let
  sec = toString <secrets>;
  hostname = config.krebs.build.host.name;
  user = config.services.nginx.user;
  group = config.services.nginx.group;
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

  services.nginx = {
    enable = mkDefault true;
    virtualHosts = {
      "euer.krebsco.de" = {
        #serverAliases = [ "blog.euer.krebsco.de" "blog.${hostname}" ];
        enableACME = true;
        forceSSL = true;
        default = true;
        root = base-dir;
      };
    };
  };
  state = [ base-dir ];
}
