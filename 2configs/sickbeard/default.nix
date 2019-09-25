{ pkgs, config, ... }:
let
  pkg = pkgs.callPackage ./sickgear.nix {};
  external-ip = config.krebs.build.host.nets.internet.ip4.addr;
in {
  services.sickbeard =
    {
      enable = true;
      package = pkg;
      user = "sickbeard";
      group = "download";
      port = 8280;
    };
    services.nginx.virtualHosts."sick.makefu.r" = {
      locations."/".proxyPass = http://localhost:8280;
      extraConfig = ''
        if ( $server_addr = "${external-ip}" ) {
        return 403;
        }
      '';
    };
    users.users.sickbeard.extraGroups = [ "nginx" ];
  }
