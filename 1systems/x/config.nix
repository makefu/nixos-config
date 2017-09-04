#
#
#
{ config, pkgs, ... }:
with import <stockholm/lib>;

{
  imports =
    [ # base
      <stockholm/makefu>
      <stockholm/makefu/2configs/main-laptop.nix>
      <stockholm/makefu/2configs/extra-fonts.nix>
      <stockholm/makefu/2configs/tools/all.nix>
      <stockholm/makefu/2configs/laptop-backup.nix>
      <stockholm/makefu/2configs/dnscrypt/client.nix>
      <stockholm/makefu/2configs/avahi.nix>

      # Debugging
      # <stockholm/makefu/2configs/disable_v6.nix>

      # Testing
      # <stockholm/makefu/2configs/deployment/gitlab.nix>
      # <stockholm/makefu/2configs/deployment/wiki-irc-bot>

      # <stockholm/makefu/2configs/torrent.nix>
      # <stockholm/makefu/2configs/lanparty/lancache.nix>
      # <stockholm/makefu/2configs/lanparty/lancache-dns.nix>
      # <stockholm/makefu/2configs/deployment/dirctator.nix>
      # <stockholm/makefu/2configs/vncserver.nix>
      # <stockholm/makefu/2configs/deployment/led-fader>
      # <stockholm/makefu/2configs/deployment/hound>

      # Krebs
      <stockholm/makefu/2configs/tinc/retiolum.nix>

      # applications
      <stockholm/makefu/2configs/exim-retiolum.nix>
      <stockholm/makefu/2configs/mail-client.nix>
      <stockholm/makefu/2configs/printer.nix>
      <stockholm/makefu/2configs/task-client.nix>

      # Virtualization
      <stockholm/makefu/2configs/virtualisation/libvirt.nix>
      <stockholm/makefu/2configs/virtualisation/docker.nix>
      <stockholm/makefu/2configs/virtualisation/virtualbox.nix>
      {
        networking.firewall.allowedTCPPorts = [ 8080 ];
        networking.nat = {
          enable = true;
          externalInterface = "wlp3s0";
          internalInterfaces = [ "vboxnet0" ];
        };
      }

      # Services
      <stockholm/makefu/2configs/git/brain-retiolum.nix>
      <stockholm/makefu/2configs/tor.nix>
      <stockholm/makefu/2configs/vpn/vpngate.nix>
      <stockholm/makefu/2configs/steam.nix>
      # <stockholm/makefu/2configs/buildbot-standalone.nix>

      # Hardware
      <stockholm/makefu/2configs/hw/tp-x230.nix>
      <stockholm/makefu/2configs/hw/rtl8812au.nix>
      <stockholm/makefu/2configs/hw/exfat-nofuse.nix>
      <stockholm/makefu/2configs/hw/wwan.nix>
      <stockholm/makefu/2configs/hw/stk1160.nix>
      # <stockholm/makefu/2configs/rad1o.nix>

      # Filesystem
      <stockholm/makefu/2configs/fs/sda-crypto-root-home.nix>

      # Security
      <stockholm/makefu/2configs/sshd-totp.nix>
      {
        programs.adb.enable = true;
      }

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
  networking.firewall.trustedInterfaces = [ "vboxnet0" ];

  krebs.build.host = config.krebs.hosts.x;

  krebs.tinc.retiolum.connectTo = [ "omo" "gum" "prism" ];

  networking.extraHosts = ''
    192.168.1.11 omo.local
  '';
  # hard dependency because otherwise the device will not be unlocked
  boot.initrd.luks.devices = [ { name = "luksroot"; device = "/dev/sda2"; allowDiscards=true; }];
}
