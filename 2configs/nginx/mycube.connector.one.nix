{ config, lib, pkgs, ... }:

with config.krebs.lib;
let
  hostname = config.krebs.build.host.name;
  external-ip = head config.krebs.build.host.nets.internet.addrs4;
in {
  services.redis.enable = true;

  krebs.nginx = {
    enable = mkDefault true;
    servers = {
      mybox-connector-one = {
        listen = [ "${external-ip}:80" ];
        server-names = [
          "mycube.connector.one"
          "mybox.connector.one"
        ];
        locations = singleton (nameValuePair "/" ''
          proxy_set_header   Host $host;
          proxy_set_header   X-Real-IP          $remote_addr;
          proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_pass http://localhost:8001/;
        '');
      };
    };
  };
}
