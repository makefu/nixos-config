{ lib, config, ... }:
let
  web-port = 19453;
  hostn = "gitlab.makefu.r";
  internal-ip = config.krebs.build.host.nets.retiolum.ip4.addr;
in {

  services.gitlab = {
    enable = true;
    https = false;
    port = web-port;
    secrets = import <secrets/gitlab/secrets.nix>;
    databasePassword = import <secrets/gitlab/dbpw.nix>;
    initialRootEmail = "makefu@x.r";
    initialRootPassword = import <secrets/gitlab/rootpw.nix>;
    host = hostn;
    smtp = {
      enable = true;
      domain = "r";
      enableStartTLSAuto = false;
      port = 25;
    };
  };

  services.nginx = {
    enable = lib.mkDefault true;
    virtualHosts."${hostn}".locations."/" = {
        proxyPass  = "http://localhost:${toString web-port}/";
        extraConfig = ''
          if ( $server_addr != "${internal-ip}" ) {
            return 403;
          }
          proxy_set_header   Host             $host;
          proxy_set_header   X-Real-IP        $remote_addr;
          proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
      '';
    };
  };
}
