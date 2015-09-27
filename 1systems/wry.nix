{ config, lib, pkgs, ... }:

let

  ip = (lib.elemAt config.krebs.build.host.nets.internet.addrs4 0);
in {
  imports = [
    ../../tv/2configs/CAC-CentOS-7-64bit.nix
    ../2configs/base.nix
    ../2configs/tinc-basic-retiolum.nix
    {
    }
  ];
  networking.firewall.allowPing = true;
  networking.interfaces.enp2s1.ip4 = [
      {
        address = ip;
        prefixLength = 24;
      }
    ];
    networking.defaultGateway = "104.233.80.1";
    networking.nameservers = [
      "8.8.8.8"
    ];

  # based on ../../tv/2configs/CAC-Developer-2.nix
  sound.enable = false;
  krebs.build = {
    user = config.krebs.users.makefu;
    target = "root@${ip}";
    host = config.krebs.hosts.wry;
  };

}
