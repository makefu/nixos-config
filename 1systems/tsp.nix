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
      ../2configs/fs/sda-crypto-root.nix
      # hardware specifics are in here
      ../2configs/hw/tp-x200.nix #< imports tp-x2x0.nix

      ../2configs/disable_v6.nix
      ../2configs/rad1o.nix

      ../2configs/zsh-user.nix
      ../2configs/exim-retiolum.nix
    ];
  # not working in vm
  krebs.build.host = config.krebs.hosts.tsp;
  krebs.build.user = config.krebs.users.makefu;
  krebs.build.target = "root@tsp";


  networking.firewall.allowedTCPPorts = [
    25
  ];

  krebs.build.deps = {
    nixpkgs = {
      url = https://github.com/NixOS/nixpkgs;
      #url = https://github.com/makefu/nixpkgs;
      rev = "13576925552b1d0751498fdda22e91a055a1ff6c";
    };
  };
}
