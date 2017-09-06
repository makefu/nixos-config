{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
let
  external-ip = config.krebs.build.host.nets.internet.ip4.addr;
  internal-ip = config.krebs.build.host.nets.retiolum.ip4.addr;
  hn = config.krebs.build.host.name;
in {
  krebs.bepasty.servers."paste.r".nginx.extraConfig = ''
    if ( $server_addr = "${external-ip}" ) {
      return 403;
    }
  '';
  krebs.tinc_graphs = {
    enable = true;
    nginx = {
      enable = true;
      # TODO: remove hard-coded hostname
      complete = {
        extraConfig = ''
          if ( $server_addr = "${external-ip}" ) {
            return 403;
          }
        '';
        serverAliases = [
          "graph.r"
          "graph.${hn}" "graph.${hn}.r"
        ];
      };
      anonymous = {
        forceSSL = true;
        enableACME = true;
      };
    };
  };
}
