{config, lib, ...}:

with config.krebs.lib;
let
  sec = toString <secrets>;
  ssl_cert = "${sec}/wildcard.krebsco.de.crt";
  ssl_key  = "${sec}/wildcard.krebsco.de.key";
in {
  # mattermost docker config and deployment guide: git.euer.krebsco.de
  virtualisation.docker.enable = true;
  users.extraUsers.${config.krebs.build.user.name}.extraGroups = [ "docker" ];
  krebs.nginx = {
    enable = true;
    servers.mattermost = {
      listen = [ "80" "443 ssl" ];
      server-names = [ "mattermost.euer.krebsco.de" ];
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

        client_max_body_size 4G;
        keepalive_timeout 10;

      '';
      locations = [
        (nameValuePair "/" ''
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
          proxy_set_header   Host $host;
          proxy_set_header   X-Real-IP          $remote_addr;
          proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_redirect      off;
          proxy_pass http://localhost:8065/;
        '')
      ];
    };
  };
}
