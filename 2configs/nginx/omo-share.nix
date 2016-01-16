{ config, lib, pkgs, ... }:

with lib;
let
  hostname = config.krebs.build.host.name;
  # TODO local-ip from the nets config
  local-ip = "192.168.1.11";
  # local-ip = head config.krebs.build.host.nets.retiolum.addrs4;
in {
  krebs.nginx = {
    enable = mkDefault true;
    servers = {
      omo-share = {
        listen = [ "${local-ip}:80" ];
        locations = singleton (nameValuePair "/" ''
          autoindex on;
          root /media;
          limit_rate_after 100m;
          limit_rate 5m;
          mp4_buffer_size     4M;
          mp4_max_buffer_size 10M;
          allow all;
          access_log off;
          keepalive_timeout  65;
          keepalive_requests 200;
          reset_timedout_connection on;
          sendfile on;
          tcp_nopush on;
          gzip off;
        '');
      };
    };
  };
}
