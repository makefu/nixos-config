#
#
#
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../2configs/main-laptop.nix #< base-gui + zsh

      # Krebs
      ../2configs/tinc-basic-retiolum.nix
      #../2configs/disable_v6.nix


      # applications

      ../2configs/exim-retiolum.nix
      ../2configs/mail-client.nix
      ../2configs/printer.nix
      #../2configs/virtualization.nix
      ../2configs/virtualization.nix
      ../2configs/virtualization-virtualbox.nix
      ../2configs/wwan.nix

      # services
      ../2configs/git/brain-retiolum.nix
      ../2configs/tor.nix

      # hardware specifics are in here
      ../2configs/hw/tp-x220.nix
      # mount points
      ../2configs/fs/sda-crypto-root-home.nix
      # ../2configs/mediawiki.nix
      #../2configs/wordpress.nix
    ];
  nixpkgs.config.packageOverrides = pkgs: {
    tinc = pkgs.tinc_pre;
    buildbot = let
      pkgs1509 = import (fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz) {};
      in pkgs1509.buildbot;
  };
  makefu.buildbot.master.enable = true;

  #krebs.Reaktor.enable = true;
  #krebs.Reaktor.nickname = "makefu|r";
  # nix.binaryCaches = [ "http://acng.shack/nixos" "https://cache.nixos.org" ];

  environment.systemPackages = with pkgs;[
    get
    virtmanager
    gnome3.dconf
    krebspaste
    ];

  services.logind.extraConfig = "HandleLidSwitch=ignore";
  # configure pulseAudio to provide a HDMI sink as well
  hardware.pulseaudio.configFile = pkgs.writeText "pulse-default-pa" ''
    ${builtins.readFile "${config.hardware.pulseaudio.package}/etc/pulse/default.pa"}
    load-module module-alsa-sink device=hw:0,3 sink_properties=device.description="HDMIOutput" sink_name="HDMI"'';
  networking.firewall.allowedTCPPorts = [
    25
  ];

  krebs.build.host = config.krebs.hosts.pornocauster;
}
