#
#
#
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../2configs/base.nix
      ../2configs/main-laptop.nix #< base-gui

      # Krebs
      ../2configs/tinc-basic-retiolum.nix
      #../2configs/disable_v6.nix

      #../2configs/sda-crypto-root.nix
      ../2configs/sda-crypto-root-home.nix

      ../2configs/zsh-user.nix

      # applications
      ../2configs/exim-retiolum.nix
      ../2configs/virtualization.nix
      ../2configs/wwan.nix

      # hardware specifics are in here
      ../2configs/tp-x220.nix
    ];

  krebs.build.host = config.krebs.hosts.pornocauster;
  krebs.build.user = config.krebs.users.makefu;
  krebs.build.target = "root@pornocauster";

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
