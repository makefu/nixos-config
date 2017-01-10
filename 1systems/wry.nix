{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
let

  external-ip = config.krebs.build.host.nets.internet.ip4.addr;
  internal-ip = config.krebs.build.host.nets.retiolum.ip4.addr;
in {
  imports = [
      ../.
      # TODO: copy this config or move to krebs
      ../2configs/hw/CAC.nix
      ../2configs/fs/CAC-CentOS-7-64bit.nix
      ../2configs/save-diskspace.nix

      ../2configs/bepasty-dual.nix

      ../2configs/iodined.nix
      ../2configs/backup.nix

      # other nginx
      ../2configs/nginx/euer.wiki.nix
      ../2configs/nginx/euer.blog.nix
      # ../2configs/nginx/euer.test.nix

      # collectd
      ../2configs/logging/central-stats-client.nix

      ../2configs/tinc/retiolum.nix
      # ../2configs/torrent.nix
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

  # prepare graphs
  services.nginx.enable = true;
  krebs.retiolum-bootstrap.enable = true;
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
        serverAliases = [  "graphs.retiolum" "graphs.wry" "graphs.retiolum" "graphs.wry.retiolum" ];
      };
      anonymous = {
        enableSSL = true;
        forceSSL = true;
        enableACME = true;
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

  environment.systemPackages = [ pkgs.screen ];
}
