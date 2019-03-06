#
#
#
{ config, pkgs, lib, ... }:
{
  imports =
    [ # base
      <stockholm/makefu>
      <stockholm/makefu/2configs/nur.nix>
      <stockholm/makefu/2configs/home-manager>
      <stockholm/makefu/2configs/home-manager/desktop.nix>
      <stockholm/makefu/2configs/home-manager/cli.nix>
      <stockholm/makefu/2configs/home-manager/mail.nix>
      <stockholm/makefu/2configs/main-laptop.nix>
      <stockholm/makefu/2configs/extra-fonts.nix>
      <stockholm/makefu/2configs/tools/all.nix>
      <stockholm/makefu/2configs/dict.nix>
      #<stockholm/makefu/3modules/netboot_server.nix>
      #{
      #  netboot_server = {
      #    network.wan = "wlp3s0";
      #    network.lan = "enp0s25";
      #  };
      #}

      <stockholm/makefu/2configs/backup/state.nix>
      # <stockholm/makefu/2configs/dnscrypt/client.nix>
      <stockholm/makefu/2configs/avahi.nix>
      <stockholm/makefu/2configs/support-nixos.nix>

      # Debugging
      # <stockholm/makefu/2configs/disable_v6.nix>
      # <stockholm/makefu/2configs/pyload.nix>

      # Testing
      # <stockholm/makefu/2configs/deployment/gitlab.nix>
      # <stockholm/makefu/2configs/deployment/wiki-irc-bot>

      # <stockholm/makefu/2configs/torrent.nix>
      # <stockholm/makefu/2configs/deployment/dirctator.nix>
      # <stockholm/makefu/2configs/vncserver.nix>
      # <stockholm/makefu/2configs/deployment/led-fader>
      # <stockholm/makefu/2configs/deployment/hound>
      # <stockholm/makefu/2configs/deployment/photostore.krebsco.de.nix>
      # <stockholm/makefu/2configs/deployment/bureautomation/hass.nix>

      # Krebs
      <stockholm/makefu/2configs/tinc/retiolum.nix>
      <stockholm/makefu/2configs/share/gum-client.nix>


      # applications
      <stockholm/makefu/2configs/exim-retiolum.nix>
      <stockholm/makefu/2configs/mail-client.nix>
      <stockholm/makefu/2configs/printer.nix>
      <stockholm/makefu/2configs/task-client.nix>
      # <stockholm/makefu/2configs/syncthing.nix>

      # Virtualization
      <stockholm/makefu/2configs/virtualisation/libvirt.nix>
      <stockholm/makefu/2configs/virtualisation/docker.nix>
      <stockholm/makefu/2configs/virtualisation/virtualbox.nix>
      #{
      #  networking.firewall.allowedTCPPorts = [ 8080 ];
      #  networking.nat = {
      #    enable = true;
      #    externalInterface = "wlp3s0";
      #    internalInterfaces = [ "vboxnet0" ];
      #  };
      #}
      # Services
      <stockholm/makefu/2configs/git/brain-retiolum.nix>
      <stockholm/makefu/2configs/tor.nix>
      <stockholm/makefu/2configs/vpn/vpngate.nix>
      # <stockholm/makefu/2configs/buildbot-standalone.nix>
      <stockholm/makefu/2configs/remote-build/aarch64-community.nix>
      <stockholm/makefu/2configs/remote-build/gum.nix>
      { nixpkgs.overlays = [ (self: super: super.prefer-remote-fetch self super) ]; }

      # Hardware
      <stockholm/makefu/2configs/hw/tp-x230.nix>
      <stockholm/makefu/2configs/hw/mceusb.nix>
      <stockholm/makefu/2configs/hw/malduino_elite.nix>
      # <stockholm/makefu/2configs/hw/tpm.nix>
      # <stockholm/makefu/2configs/hw/rtl8812au.nix>
      <stockholm/makefu/2configs/hw/network-manager.nix>
      <stockholm/makefu/2configs/hw/stk1160.nix>
      <stockholm/makefu/2configs/hw/irtoy.nix>
      <stockholm/makefu/2configs/hw/switch.nix>
      <stockholm/makefu/2configs/hw/bluetooth.nix>
      # <stockholm/makefu/2configs/hw/rad1o.nix>
      <stockholm/makefu/2configs/hw/smartcard.nix>

      # Filesystem
      <stockholm/makefu/2configs/fs/sda-crypto-root-home.nix>

      # Security
      <stockholm/makefu/2configs/sshd-totp.nix>
      { programs.adb.enable = true; }
      # temporary
      { services.redis.enable = true; }
      <stockholm/makefu/2configs/pyload.nix>
      # <stockholm/makefu/2configs/dcpp/airdcpp.nix>
      # <stockholm/makefu/2configs/nginx/rompr.nix>
      # <stockholm/makefu/2configs/lanparty/lancache.nix>
      # <stockholm/makefu/2configs/lanparty/lancache-dns.nix>
      # <stockholm/makefu/2configs/lanparty/samba.nix>
      # <stockholm/makefu/2configs/lanparty/mumble-server.nix>

      {
        networking.wireguard.interfaces.wg0 = {
          ips = [ "10.244.0.2/24" ];
          privateKeyFile = (toString <secrets>) + "/wireguard.key";
          allowedIPsAsRoutes = true;
          peers = [
          {
            # gum
            endpoint = "${config.krebs.hosts.gum.nets.internet.ip4.addr}:51820";
            allowedIPs = [ "10.244.0.0/24" ];
            publicKey = "yAKvxTvcEVdn+MeKsmptZkR3XSEue+wSyLxwcjBYxxo=";
          }
          #{
          #  # vbob
          #  allowedIPs = [ "10.244.0.3/32" ];
          #  publicKey = "Lju7EsCu1OWXhkhdNR7c/uiN60nr0TUPHQ+s8ULPQTw=";
          #}
          ];
        };
      }
      # {
      #   services.zerotierone.enable = true;
      # }

    ];

  makefu.server.primary-itf = "wlp3s0";

  nixpkgs.config.allowUnfree = true;

  # configure pulseAudio to provide a HDMI sink as well
  networking.firewall.enable = true;
  networking.firewall.allowedUDPPorts = [ 665 26061 ];
  networking.firewall.trustedInterfaces = [ "vboxnet0" ];

  krebs.build.host = config.krebs.hosts.x;

  krebs.tinc.retiolum.connectTo = [ "omo" "gum" "prism" "nextgum" ];

  networking.extraHosts = ''
    192.168.1.11  omo.local
    80.92.65.53 www.wifionice.de wifionice.de
  '';
  # hard dependency because otherwise the device will not be unlocked
  boot.initrd.luks.devices = [ { name = "luksroot"; device = "/dev/sda2"; allowDiscards=true; }];
  # avoid full boot dir
  boot.loader.grub.configurationLimit = 3;

  environment.systemPackages = [ pkgs.passwdqc-utils ];

  # environment.variables = { GOROOT = [ "${pkgs.go.out}/share/go" ]; };
  state = [
    "/home/makefu/stockholm"
    "/home/makefu/.ssh/"
    "/home/makefu/.zsh_history"
    "/home/makefu/.bash_history"
    "/home/makefu/.zshrc"
    "/home/makefu/bin"
    "/home/makefu/.gnupg"
    "/home/makefu/.imapfilter"
    "/home/makefu/.mutt"
    "/home/makefu/docs"
    "/home/makefu/.password-store"
    "/home/makefu/.secrets-pass"
  ];

  services.syncthing.user = lib.mkForce "makefu";
  services.syncthing.dataDir = lib.mkForce "/home/makefu/.config/syncthing/";
}
