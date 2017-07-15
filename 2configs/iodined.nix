{ pkgs, config, ... }:

let
  # TODO: make this a parameter
  domain = "io.krebsco.de";
  pw = import <secrets/iodinepw.nix>;
in {
  networking.firewall.allowedUDPPorts = [ 53 ];

  services.iodine = {
    server = {
      enable = true;
      domain = domain;
      ip = "172.16.10.1/24";
      extraConfig = "-c -P ${pw} -l ${config.krebs.build.host.nets.internet.ip4.addr}";
    };
  };

}
