#
#
#
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../.
      ../2configs/main-laptop.nix #< base-gui + zsh
      ../2configs/laptop-utils.nix

      # Krebs
      #../2configs/disable_v6.nix


      # applications

      ../2configs/exim-retiolum.nix
      ../2configs/mail-client.nix
      ../2configs/printer.nix
      ../2configs/virtualization.nix
      ../2configs/virtualization-virtualbox.nix
      ../2configs/wwan.nix

      # services
      ../2configs/git/brain-retiolum.nix
      ../2configs/tor.nix
      # ../2configs/buildbot-standalone.nix

      # hardware specifics are in here
      ../2configs/hw/tp-x220.nix
      # mount points
      ../2configs/fs/sda-crypto-root-home.nix
      # ../2configs/mediawiki.nix
      #../2configs/wordpress.nix
      ../2configs/nginx/public_html.nix
    ];

  krebs.retiolum.enable = true;
  # steam
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;

  # configure pulseAudio to provide a HDMI sink as well
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    25
    80
  ];

  krebs.build.host = config.krebs.hosts.pornocauster;
}
