#
#
#
{ config, pkgs, ... }:

{
  imports =
    [ # base
      ../.
      ../2configs/main-laptop.nix
      ../2configs/extra-fonts.nix
      ../2configs/tools/all.nix
      ../2configs/laptop-backup.nix
      ../2configs/dnscrypt.nix

      # testing
      # ../2configs/openvpn/vpngate.nix
      #../2configs/temp/share-samba.nix
      # ../2configs/mediawiki.nix
      # ../2configs/wordpress.nix
      # ../2configs/nginx/public_html.nix
      # ../2configs/nginx/icecult.nix

      # ../2configs/elchos/irc-token.nix
      # ../2configs/elchos/log.nix

      #../2configs/elchos/search.nix
      #../2configs/elchos/stats.nix
      #../2configs/elchos/test/ftpservers.nix

      # ../2configs/tinc/siem.nix
      #../2configs/torrent.nix
      # temporary modules

      # ../2configs/torrent.nix
      #../2configs/temp/elkstack.nix
      # ../2configs/temp/sabnzbd.nix



      # Krebs
      # ../2configs/disable_v6.nix
      ../2configs/tinc/retiolum.nix

      # applications
      ../2configs/exim-retiolum.nix
      ../2configs/mail-client.nix
      ../2configs/printer.nix
      ../2configs/virtualization.nix
      ../2configs/virtualization-virtualbox.nix
      ../2configs/wwan.nix
      ../2configs/rad1o.nix

      # services
      #../2configs/git/brain-retiolum.nix
      ../2configs/tor.nix
      ../2configs/steam.nix
      # ../2configs/buildbot-standalone.nix

      # hardware specifics are in here
      ../2configs/hw/tp-x230.nix
      ../2configs/hw/rtl8812au.nix

      # mount points
      ../2configs/fs/sda-crypto-root-home.nix

    ];

  makefu.server.primary-itf = "wlp3s0";
  makefu.full-populate = true;
  makefu.umts.apn = "web.vodafone.de";

  nixpkgs.config.allowUnfree = true;
  krebs.nginx = {
    default404 = false;
    servers.default.listen = [ "80 default_server" ];
    servers.default.server-names = [ "_" ];
  };

  boot.extraModulePackages = [ config.boot.kernelPackages.exfat-nofuse ];
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
