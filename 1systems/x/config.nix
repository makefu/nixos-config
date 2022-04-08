#
#
#
{ config, pkgs, lib, ... }:
{
  imports =
    [
      # hardware-dependent
      # device


      ./x13
      # ./x230

      # Common Hardware Components
      <nix-ld/modules/nix-ld.nix>
      # <stockholm/makefu/2configs/hw/mceusb.nix>
      # <stockholm/makefu/2configs/hw/rtl8812au.nix>
      <stockholm/makefu/2configs/hw/network-manager.nix>
      # <stockholm/makefu/2configs/hw/stk1160.nix>
      # <stockholm/makefu/2configs/hw/irtoy.nix>
      # <stockholm/makefu/2configs/hw/malduino_elite.nix>
      <stockholm/makefu/2configs/hw/switch.nix>
      # <stockholm/makefu/2configs/hw/rad1o.nix>
      <stockholm/makefu/2configs/hw/cc2531.nix>
      <stockholm/makefu/2configs/hw/droidcam.nix>
      <stockholm/makefu/2configs/hw/smartcard.nix>
      <stockholm/makefu/2configs/hw/upower.nix>
      <stockholm/makefu/2configs/hw/nswitch.nix>
      #<stockholm/makefu/2configs/hw/ps4-compat.nix>

      # base
      <stockholm/makefu>
      <stockholm/makefu/2configs/nur.nix>
      <stockholm/makefu/2configs/home-manager>
      <stockholm/makefu/2configs/home-manager/desktop.nix>
      <stockholm/makefu/2configs/home-manager/cli.nix>
      <stockholm/makefu/2configs/home-manager/mail.nix>
      <stockholm/makefu/2configs/home-manager/taskwarrior.nix>

      <stockholm/makefu/2configs/main-laptop.nix>
      <stockholm/makefu/2configs/kdeconnect.nix>
      <stockholm/makefu/2configs/extra-fonts.nix>
      <stockholm/makefu/2configs/editor/neovim>
      <stockholm/makefu/2configs/tools/all.nix>
      { programs.adb.enable = true; }
      {
        services.openssh.hostKeys = [
          { bits = 4096; path = (toString <secrets/ssh_host_rsa_key>); type = "rsa";}
        ];
      }

      #{
      #  users.users.makefu.packages = with pkgs;[ mpc_cli ncmpcpp ];
      #  services.ympd.enable = true;
      #  services.mpd = {
      #    enable = true;
      #    extraConfig = ''
      #      log_level "default"
      #      auto_update "yes"

      #      audio_output {
      #        type "httpd"
      #        name "lassulus radio"
      #        encoder "vorbis" # optional
      #        port "8000"
      #        quality "5.0" # do not define if bitrate is defined
      #        # bitrate "128" # do not define if quality is defined
      #        format "44100:16:2"
      #        always_on "yes" # prevent MPD from disconnecting all listeners when playback is stopped.
      #        tags "yes" # httpd supports sending tags to listening streams.
      #      }
      #    '';
      #  };
      #}

      # { systemd.services.docker.wantedBy = lib.mkForce []; }
      <stockholm/makefu/2configs/dict.nix>
      # <stockholm/makefu/2configs/legacy_only.nix>
      #<stockholm/makefu/3modules/netboot_server.nix>
      #{
      #  netboot_server = {
      #    network.wan = "wlp3s0";
      #    network.lan = "enp0s25";
      #  };
      #}

      # Restore:
      # systemctl cat borgbackup-job-state
      # export BORG_PASSCOMMAND BORG_REPO BORG_RSH
      # borg list "$BORG_REPO"
      # mount newroot somewhere && cd somewhere
      # borg extract  "$BORG_REPO::x-state-2019-04-17T01:41:51"  --progress # < extract to cwd
      <stockholm/makefu/2configs/backup/state.nix>

      # <stockholm/makefu/2configs/dnscrypt/client.nix>
      <stockholm/makefu/2configs/avahi.nix>
      <stockholm/makefu/2configs/support-nixos.nix>

      # Debugging
      # <stockholm/makefu/2configs/disable_v6.nix>
      # <stockholm/makefu/2configs/pyload.nix>

      # Testing
      #{
      #  services.nginx = {
      #    enable = true;
      #    recommendedProxySettings = true;
      #    virtualHosts.local = {
      #      default = true;
      #      locations."/".proxyPass= "http://localhost:4567";
      #    };
      #  };
      #  services.gollum = {
      #    enable = true;
      #    extraConfig = ''
      #      Gollum::Hook.register(:post_commit, :hook_id) do |committer, sha1|
      #        File.open('/tmp/lol', 'w') { |file| file.write(self.to_s) }
      #      end
      #    '';
      #  };
      #}
      # <stockholm/makefu/2configs/deployment/gitlab.nix>
      # <stockholm/makefu/2configs/deployment/docker/etherpad.nix>
      # <stockholm/makefu/2configs/deployment/wiki-irc-bot>

      # <stockholm/makefu/2configs/torrent.nix>
      # <stockholm/makefu/2configs/deployment/dirctator.nix>
      # <stockholm/makefu/2configs/vncserver.nix>
      # <stockholm/makefu/2configs/deployment/led-fader>
      # <stockholm/makefu/2configs/deployment/hound>
      # <stockholm/makefu/2configs/deployment/photostore.krebsco.de.nix>
      # <stockholm/makefu/2configs/deployment/bureautomation/hass.nix>
      <stockholm/makefu/2configs/bureautomation/office-radio>

      # Krebs
      <stockholm/makefu/2configs/tinc/retiolum.nix>
      # <stockholm/makefu/2configs/share/anon-ftp.nix>
      # <stockholm/makefu/2configs/share/anon-sftp.nix>
      <stockholm/makefu/2configs/share/gum-client.nix>
      <stockholm/makefu/2configs/share/hetzner-client.nix>
      <stockholm/makefu/2configs/share>
      # <stockholm/makefu/2configs/share/temp-share-samba.nix>


      # applications
      <stockholm/makefu/2configs/exim-retiolum.nix>
      <stockholm/makefu/2configs/mail-client.nix>
      <stockholm/makefu/2configs/printer.nix>
      # <stockholm/makefu/2configs/syncthing.nix>
      <stockholm/makefu/2configs/sync>

      # Virtualization
      # <stockholm/makefu/2configs/virtualisation/libvirt.nix>
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
      # <stockholm/makefu/2configs/vpn/vpngate.nix>
      # <stockholm/makefu/2configs/buildbot-standalone.nix>
      <stockholm/makefu/2configs/remote-build/aarch64-community.nix>
      # <stockholm/makefu/2configs/remote-build/gum.nix>
      # { nixpkgs.overlays = [ (self: super: super.prefer-remote-fetch self super) ]; }

      # <stockholm/makefu/2configs/binary-cache/gum.nix>
      <stockholm/makefu/2configs/binary-cache/lass.nix>



      # Security
      # <stockholm/makefu/2configs/sshd-totp.nix>

      # temporary
      # { services.redis.enable = true; }
      # { services.mongodb.enable = true; }
      # { services.elasticsearch.enable = true; }
      # <stockholm/makefu/2configs/deployment/nixos.wiki>
      # <stockholm/makefu/2configs/home/photoprism.nix>
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
    ];


  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.oraclejdk.accept_license = true;



  # configure pulseAudio to provide a HDMI sink as well
  networking.firewall.enable = true;
  networking.firewall.allowedUDPPorts = [ 665 26061 1514 ];
  networking.firewall.trustedInterfaces = [ "vboxnet0" "enp0s25" ];

  krebs.build.host = config.krebs.hosts.x;

  #krebs.tinc.retiolum.connectTo = lib.mkForce [ "gum" ];
  #krebs.tinc.retiolum.extraConfig = "AutoConnect = no";


  environment.systemPackages = [ pkgs.passwdqc-utils ];

  # environment.variables = { GOROOT = [ "${pkgs.go.out}/share/go" ]; };
  state = [
    "/home/makefu/stockholm"
    "/home/makefu/.ssh/"
    "/home/makefu/.zsh_history"
    "/home/makefu/.bash_history"
    "/home/makefu/bin"
    "/home/makefu/.gnupg"
    "/home/makefu/.imapfilter"
    "/home/makefu/.mutt"
    "/home/makefu/docs"
    "/home/makefu/notes"
    "/home/makefu/.password-store"
    "/home/makefu/.secrets-pass"
    "/home/makefu/.config/syncthing"
  ];

  # services.syncthing.user = lib.mkForce "makefu";
  # services.syncthing.dataDir = lib.mkForce "/home/makefu/.config/syncthing/";
}
