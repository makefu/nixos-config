{ config, lib, pkgs, ... }:

with config.krebs.lib;
let

  external-ip = head config.krebs.build.host.nets.internet.addrs4;
  internal-ip = head config.krebs.build.host.nets.retiolum.addrs4;
in {
  imports = [
      ../.
      # TODO: copy this config or move to krebs
      ../../tv/2configs/hw/CAC.nix
      ../../tv/2configs/fs/CAC-CentOS-7-64bit.nix
      ../2configs/unstable-sources.nix
      ../2configs/headless.nix
      ../2configs/tinc-basic-retiolum.nix

      ../2configs/bepasty-dual.nix

      ../2configs/iodined.nix


      # other nginx
      ../2configs/nginx/euer.wiki.nix
      ../2configs/nginx/euer.blog.nix
      ../2configs/nginx/euer.test.nix

      # collectd
      ../2configs/collectd/collectd-base.nix
  ];

  krebs.build.host = config.krebs.hosts.wry;

  krebs.Reaktor = {
    nickname = "Reaktor|bot";
    channels = [ "#krebs" "#shackspace" "#binaergewitter" ];
    enable = true;
    plugins = with pkgs.ReaktorPlugins;[
                               titlebot
                               # stockholm-issue
                               nixos-version
                               shack-correct
                               sed-plugin
                               random-emoji ];
  };

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
    firewall = {
      allowPing = true;
      logRefusedConnections = false;
      allowedTCPPorts = [ 53 80 443 ];
      allowedUDPPorts = [ 655 53 ];
    };
    interfaces.enp2s1.ip4 = [{
      address = external-ip;
      prefixLength = 24;
    }];
    defaultGateway = "104.233.87.1";
    nameservers = [ "8.8.8.8" ];
  };

  # small machine - do not forget to gc every day
  nix.gc.automatic = true;
  nix.gc.dates = "03:10";

  environment.systemPackages = [ ];
}
