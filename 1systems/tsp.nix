# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../2configs/base.nix
      ../2configs/base-gui.nix
      ../2configs/tp-x200.nix
      ../2configs/sda-crypto-root.nix
    ];
  # not working in vm
  krebs.build.host = config.krebs.hosts.tsp;
  krebs.build.user = config.krebs.users.makefu;
  krebs.build.target = "root@tsp";

  krebs.build.deps = {
    nixpkgs = {
      #url = https://github.com/NixOS/nixpkgs;
      # rev=$(curl https://nixos.org/channels/nixos-unstable/git-revision -L)
      url = https://github.com/makefu/nixpkgs;
      rev = "8b8b65da24f13f9317504e8bcba476f9161613fe";
    };
  };

  krebs.retiolum = {
    enable = true;
    hosts = ../../Zhosts;
    connectTo = [
      "gum"
      "pigstarter"
      "fastpoke"
    ];
  };

  # hardware specifics


  networking.firewall.rejectPackets = true;
  networking.firewall.allowPing = true;


  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    vim
    jq
  ];
}
