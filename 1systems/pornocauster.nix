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
      #url = https://github.com/NixOS/nixpkgs;
      # rev=$(curl https://nixos.org/channels/nixos-unstable/git-revision -L)
      url = https://github.com/makefu/nixpkgs;
      rev = "f5fe787f778b872c6b2221598501c9310cb83915";
    };
  };
}
