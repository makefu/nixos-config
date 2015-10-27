{ config, lib, pkgs, ... }:

with lib;
let

  external-ip = head config.krebs.build.host.nets.internet.addrs4;
  internal-ip = head config.krebs.build.host.nets.retiolum.addrs4;
in {
  imports = [
      # TODO: copy this config or move to krebs
      ../../tv/2configs/CAC-CentOS-7-64bit.nix
      ../2configs/base.nix
      ../2configs/unstable-sources.nix
      ../2configs/tinc-basic-retiolum.nix

      ../2configs/bepasty-dual.nix

      ../2configs/iodined.nix

      # Reaktor
      ../2configs/Reaktor/simpleExtend.nix

      # collectd
      ../2configs/collectd/collectd-base.nix
  ];

  krebs.build = {
    user = config.krebs.users.makefu;
    target = "root@wry";
    host = config.krebs.hosts.wry;
  };



  krebs.Reaktor.enable = true;

  # bepasty to listen only on the correct interfaces
  krebs.bepasty.servers.internal.nginx.listen  = [ "${internal-ip}:80" ];
  krebs.bepasty.servers.external.nginx.listen  = [ "${external-ip}:80" "${external-ip}:443 ssl" ];

  # prepare graphs
  krebs.nginx.enable = true;
  krebs.retiolum-bootstrap.enable = true;

  nixpkgs.config.packageOverrides = pkgs: { tinc = pkgs.tinc_pre; };
  krebs.tinc_graphs = {
    enable = true;
    nginx = {
      enable = true;
      # TODO: remove hard-coded hostname
      complete = {
        listen = [ "${internal-ip}:80" ];
        server-names = [ "graphs.wry" "graphs.retiolum" "graphs.wry.retiolum" ];
      };
      anonymous = {
        listen = [ "${external-ip}:80" ] ;
        server-names = [ "graphs.krebsco.de" ];
      };
    };
  };
  networking = {
    firewall.allowPing = true;
    firewall.allowedTCPPorts = [ 53 80 443 ];
    interfaces.enp2s1.ip4 = [{
      address = external-ip;
      prefixLength = 24;
    }];
    defaultGateway = "104.233.87.1";
    nameservers = [ "8.8.8.8" ];
  };


  # based on ../../tv/2configs/CAC-Developer-2.nix
  sound.enable = false;
}
