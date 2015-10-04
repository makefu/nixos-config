{ config, lib, pkgs, ... }:

let

  ip = (lib.head config.krebs.build.host.nets.internet.addrs4);
in {
  imports = [
    ../../tv/2configs/CAC-CentOS-7-64bit.nix
    ../2configs/base.nix
    ../2configs/base-sources.nix
    ../2configs/tinc-basic-retiolum.nix
  ];

  networking.firewall.allowPing = true;
  networking.interfaces.enp2s1.ip4 = [
      {
        address = ip;
        prefixLength = 24;
      }
    ];
    networking.defaultGateway = "104.233.87.1";
    networking.nameservers = [
      "8.8.8.8"
    ];

  # based on ../../tv/2configs/CAC-Developer-2.nix
  sound.enable = false;

  # prepare graphs
  nixpkgs.config.packageOverrides = pkgs: { tinc = pkgs.tinc_pre; };
  krebs.nginx.enable = true;
  makefu.tinc_graphs.enable = true;
  makefu.tinc_graphs.krebsNginx = {
    enable = true;
    hostnames_complete = [ "graphs.wry" "graphs.wry.retiolum" ];
    # TODO: remove hard-coded path
    hostnames_anonymous = [ "graphs.krebsco.de" ];
  };
  networking.firewall.allowedTCPPorts = [80];

  krebs.build = {
    user = config.krebs.users.makefu;
    target = "root@${ip}";
    host = config.krebs.hosts.wry;
  };

}
