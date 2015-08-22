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
      #../2configs/sda-crypto-root.nix
      ../2configs/sda-crypto-root-home.nix
      # hardware specifics are in here
      ../2configs/tp-x200.nix

      #../2configs/disable_v6.nix
      #../2configs/rad1o.nix

      #../2configs/exim-retiolum.nix
    ];
  # not working in vm
  krebs.build.host = config.krebs.hosts.pornocauster;
  krebs.build.user = config.krebs.users.makefu;
  krebs.build.target = "root@localhost";

  boot.kernelModules = [ "kvm-intel" ];


  networking.firewall.allowedTCPPorts = [
    25
  ];

  krebs.build.deps = {
    nixpkgs = {
      #url = https://github.com/NixOS/nixpkgs;
      # rev=$(curl https://nixos.org/channels/nixos-unstable/git-revision -L)
      url = https://github.com/makefu/nixpkgs;
      #rev = "8b8b65da24f13f9317504e8bcba476f9161613fe";
      rev = "f5fe787f778b872c6b2221598501c9310cb83915";
    };
  };
}
