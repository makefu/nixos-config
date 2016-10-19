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
      ../2configs/laptop-backup.nix

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
      ../2configs/steam.nix
      # ../2configs/buildbot-standalone.nix

      # hardware specifics are in here
      ../2configs/hw/tp-x220.nix
      ../2configs/hw/rtl8812au.nix
      ../2configs/hw/bcm4352.nix
      # mount points
      ../2configs/fs/sda-crypto-root-home.nix
      # ../2configs/mediawiki.nix
      #../2configs/wordpress.nix
      ../2configs/nginx/public_html.nix

      ../2configs/tinc/retiolum.nix
      # temporary modules
      ../2configs/temp/share-samba.nix
      ../2configs/laptop-backup.nix
      # ../2configs/temp/elkstack.nix
      # ../2configs/temp/sabnzbd.nix
      ../2configs/tinc/siem.nix
      #../2configs/torrent.nix
    ];
  makefu.full-populate = true;

  krebs.nginx = {
    default404 = false;
    servers.default.listen = [ "80 default_server" ];
    servers.default.server-names = [ "_" ];
  };

  environment.systemPackages = [ pkgs.passwdqc-utils pkgs.bintray-upload ];

  virtualisation.docker.enable = true;

  # configure pulseAudio to provide a HDMI sink as well
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 24800 26061 8000 3000 ];
  networking.firewall.allowedUDPPorts = [ 665 26061 ];

  krebs.build.host = config.krebs.hosts.x;

  krebs.tinc.retiolum.connectTo = [ "omo" "gum" "prism" ];

  networking.extraHosts = ''
    192.168.1.11 omo.local
  '';
  # hard dependency because otherwise the device will not be unlocked
  boot.initrd.luks.devices = [ { name = "luksroot"; device = "/dev/sda2"; allowDiscards=true; }];
}
