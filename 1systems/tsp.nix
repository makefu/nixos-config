#
#
#
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../2configs/base.nix
      ../2configs/base-gui.nix
      ../2configs/tinc-basic-retiolum.nix
      ../2configs/sda-crypto-root.nix
      # hardware specifics are in here
      ../2configs/tp-x200.nix
    ];
  # not working in vm
  krebs.build.host = config.krebs.hosts.tsp;
  krebs.build.user = config.krebs.users.makefu;
  krebs.build.target = "root@tsp";

  krebs.exim-retiolum.enable = true;
  networking.firewall.allowedTCPPorts = [
  # nginx runs on 80
  # graphite-web runs on 8080, carbon cache runs on 2003 tcp and udp
    25
  ];

  krebs.build.deps = {
    nixpkgs = {
      #url = https://github.com/NixOS/nixpkgs;
      # rev=$(curl https://nixos.org/channels/nixos-unstable/git-revision -L)
      url = https://github.com/makefu/nixpkgs;
      rev = "8b8b65da24f13f9317504e8bcba476f9161613fe";
    };
  };

}
