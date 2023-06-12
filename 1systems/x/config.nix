{ config, pkgs, lib, self, ... }:
{
  imports =
    [

      # ./x230
      ./x13

      (self + "/2configs/default.nix")

      ## Common Hardware Components
      # (self + "/makefu/2configs/hw/mceusb.nix")
      # (self + "/2configs/hw/rtl8812au.nix")
      (self + "/2configs/hw/network-manager.nix")
      # (self + "/2configs/hw/stk1160.nix")
      # (self + "/2configs/hw/irtoy.nix")
      # (self + "/2configs/hw/malduino_elite.nix")
      (self + "/2configs/hw/switch.nix")
      # (self + "/2configs/hw/rad1o.nix")
      (self + "/2configs/hw/cc2531.nix")
      (self + "/2configs/hw/droidcam.nix")
      (self + "/2configs/hw/smartcard.nix")
      (self + "/2configs/hw/upower.nix")
      #(self + "/2configs/hw/ps4-compat.nix")

      # base
      (self + "/2configs/nur.nix")
      (self + "/2configs/home-manager")
      (self + "/2configs/home-manager/desktop.nix")
      (self + "/2configs/home-manager/cli.nix")
      (self + "/2configs/home-manager/mail.nix")
      (self + "/2configs/home-manager/taskwarrior.nix")

      (self + "/2configs/main-laptop.nix")
      (self + "/2configs/kdeconnect.nix")
      (self + "/2configs/extra-fonts.nix")
      (self + "/2configs/editor/neovim")
      (self + "/2configs/tools/all.nix")
      { programs.adb.enable = true; }
      {
        services.openssh.hostKeys = [
          { bits = 4096; path = (toString <secrets/ssh_host_rsa_key>); type = "rsa";}
        ];
      }
      #{
      #  imports = [
      #    (self + "/2configs/bureautomation/rhasspy.nix")
      #  ];
      #  services.pipewire.config.pipewire-pulse = {
      #    "pulse.properties"."server.address" = [ "unix:native" "tcp:4713" ];
      #  };
      #  networking.firewall.allowedTCPPorts = [ 4713 ];

      #}

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
      # (self + "/2configs/dict.nix")
      # (self + "/2configs/legacy_only.nix")
      #(self + "/3modules/netboot_server.nix")
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
      (self + "/2configs/backup/state.nix")

      # (self + "/2configs/dnscrypt/client.nix")
      (self + "/2configs/avahi.nix")
      (self + "/2configs/support-nixos.nix")

      # Debugging
      # (self + "/2configs/disable_v6.nix")
      # (self + "/2configs/pyload.nix")

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
      # (self + "/2configs/deployment/gitlab.nix")
      # (self + "/2configs/deployment/docker/etherpad.nix")
      # (self + "/2configs/deployment/wiki-irc-bot")

      # (self + "/2configs/torrent.nix")
      # (self + "/2configs/deployment/dirctator.nix")
      # (self + "/2configs/vncserver.nix")
      # (self + "/2configs/deployment/led-fader")
      # (self + "/2configs/deployment/hound")
      # (self + "/2configs/deployment/photostore.krebsco.de.nix")
      # (self + "/2configs/deployment/bureautomation/hass.nix")
      # (self + "/2configs/bureautomation/office-radio")

      # Krebs
      (self + "/2configs/tinc/retiolum.nix")
      # (self + "/2configs/share/anon-ftp.nix")
      # (self + "/2configs/share/anon-sftp.nix")
      (self + "/2configs/share/gum-client.nix")
      (self + "/2configs/share")
      # (self + "/2configs/share/temp-share-samba.nix")


      # applications
      # (self + "/2configs/exim-retiolum.nix")
      (self + "/2configs/mail-client.nix")
      (self + "/2configs/printer.nix")
      # (self + "/2configs/syncthing.nix")
      # (self + "/2configs/sync")

      # Virtualization
      # (self + "/2configs/virtualisation/libvirt.nix")
      (self + "/2configs/virtualisation/docker.nix")
      (self + "/2configs/virtualisation/virtualbox.nix")
      #{
      #  networking.firewall.allowedTCPPorts = [ 8080 ];
      #  networking.nat = {
      #    enable = true;
      #    externalInterface = "wlp3s0";
      #    internalInterfaces = [ "vboxnet0" ];
      #  };
      #}
      # Services
      (self + "/2configs/git/brain-retiolum.nix")
      (self + "/2configs/tor.nix")
      # (self + "/2configs/vpn/vpngate.nix")
      # (self + "/2configs/buildbot-standalone.nix")
      (self + "/2configs/remote-build/aarch64-community.nix")
      # (self + "/2configs/remote-build/gum.nix")
      # { nixpkgs.overlays = [ (self: super: super.prefer-remote-fetch self super) ]; }

      # (self + "/2configs/binary-cache/gum.nix")
      (self + "/2configs/binary-cache/lass.nix")



      # Security
      # (self + "/2configs/sshd-totp.nix")

      # temporary
      # { services.redis.enable = true; }
      # citadel exporter
      # { services.mongodb.enable = true; }
      # { services.elasticsearch.enable = true; }
      # (self + "/2configs/deployment/nixos.wiki")
      # (self + "/2configs/home/photoprism.nix")
      # (self + "/2configs/dcpp/airdcpp.nix")
      # (self + "/2configs/nginx/rompr.nix")
      # (self + "/2configs/lanparty/lancache.nix")
      # (self + "/2configs/lanparty/lancache-dns.nix")
      # (self + "/2configs/lanparty/samba.nix")
      # (self + "/2configs/lanparty/mumble-server.nix")
      (self + "/2configs/wireguard/wiregrill.nix")

#      {
#        networking.wireguard.interfaces.wg0 = {
#          ips = [ "10.244.0.2/24" ];
#          privateKeyFile = (toString <secrets>) + "/wireguard.key";
#          allowedIPsAsRoutes = true;
#          peers = [
#          {
#            # gum
#            endpoint = "${config.krebs.hosts.gum.nets.internet.ip4.addr}:51820";
#            allowedIPs = [ "10.244.0.0/24" ];
#            publicKey = "yAKvxTvcEVdn+MeKsmptZkR3XSEue+wSyLxwcjBYxxo=";
#          }
#          #{
#          #  # vbob
#          #  allowedIPs = [ "10.244.0.3/32" ];
#          #  publicKey = "Lju7EsCu1OWXhkhdNR7c/uiN60nr0TUPHQ+s8ULPQTw=";
#          #}
#          ];
#        };
#      }
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
