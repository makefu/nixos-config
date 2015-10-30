{ config, lib, pkgs, ... }:

with lib;
let
  external-ip = head config.krebs.build.host.nets.internet.addrs4;
  internal-ip = head config.krebs.build.host.nets.retiolum.addrs4;
in {
  imports = [
      # TODO: copy this config or move to krebs
      ../2configs/base.nix
      ../2configs/base-sources.nix
      ../2configs/tinc-basic-retiolum.nix
      ../2configs/headless.nix
      # ../2configs/iodined.nix

      # Reaktor
      ../2configs/Reaktor/simpleExtend.nix
  ];

  krebs.build = {
    user = config.krebs.users.makefu;
    target = "root@gum.krebsco.de";
    host = config.krebs.hosts.gum;
  };

  krebs.Reaktor.enable = true;

  # prepare graphs
  krebs.nginx.enable = true;

  networking = {
    firewall.allowPing = true;
    firewall.allowedTCPPorts = [ 80 443 655 ];
    firewall.allowedUDPPorts = [ 655 ];
    interfaces.enp2s1.ip4 = [{
      address = external-ip;
      prefixLength = 24;
    }];
    defaultGateway = "195.154.108.1";
    nameservers = [ "8.8.8.8" ];
  };

  # based on ../../tv/2configs/CAC-Developer-2.nix
}
