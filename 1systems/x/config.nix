#
#
#
{ config, pkgs, ... }:
with import <stockholm/lib>;

{
  imports =
    [ # base
      ../.
      ../2configs/main-laptop.nix
      ../2configs/extra-fonts.nix
      ../2configs/tools/all.nix
      ../2configs/laptop-backup.nix
      ../2configs/dnscrypt.nix
      ../2configs/avahi.nix

      # Debugging
      # ../2configs/disable_v6.nix

      # Testing
      # ../2configs/lanparty/lancache.nix
      # ../2configs/lanparty/lancache-dns.nix
      # ../2configs/deployment/dirctator.nix
      # ../2configs/vncserver.nix
      # ../2configs/deployment/led-fader
      # ../2configs/deployment/hound

      # development
      ../2configs/sources

      # Krebs
      ../2configs/tinc/retiolum.nix

      # applications
      ../2configs/exim-retiolum.nix
      ../2configs/mail-client.nix
      ../2configs/printer.nix
      ../2configs/task-client.nix

      # Virtualization
      ../2configs/virtualization.nix
      ../2configs/docker.nix
      ../2configs/virtualization-virtualbox.nix

      # Services
      ../2configs/git/brain-retiolum.nix
      ../2configs/tor.nix
      ../2configs/steam.nix
      # ../2configs/buildbot-standalone.nix

      # Hardware
      ../2configs/hw/tp-x230.nix
      ../2configs/hw/rtl8812au.nix
      ../2configs/hw/exfat-nofuse.nix
      ../2configs/hw/wwan.nix
      # ../2configs/hw/stk1160.nix
      # ../2configs/rad1o.nix

      # Filesystem
      ../2configs/fs/sda-crypto-root-home.nix

      # Security
      ../2configs/sshd-totp.nix

    ];

  makefu.server.primary-itf = "wlp3s0";
  makefu.full-populate = true;
  makefu.umts.apn = "web.vodafone.de";

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = [ pkgs.passwdqc-utils ];


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
