{ config, pkgs, lib, self, ... }:
{
  imports =
    [

      # ./x230
      ./x13

      ../../2configs/default.nix
      ## Common Hardware Components
      # (self + "/makefu/2configs/hw/mceusb.nix")
      # (self + "/2configs/hw/rtl8812au.nix")
      ../../2configs/hw/network-manager.nix
      ../../2configs/performance/disable-mitigations.nix
      # ../../2configs/hw/stk1160.nix
      # ../../2configs/hw/irtoy.nix
      # ../../2configs/hw/malduino_elite.nix
      ../../2configs/hw/switch.nix
      # ../../2configs/hw/rad1o.nix
      ../../2configs/hw/cc2531.nix
      ../../2configs/hw/droidcam.nix
      ../../2configs/hw/smartcard.nix
      ../../2configs/hw/upower.nix
      #../../2configs/hw/ps4-compat.nix

      # base
      ../../2configs/nur.nix
      ../../2configs/home-manager
      ../../2configs/home-manager/desktop.nix
      ../../2configs/home-manager/cli.nix
      ../../2configs/home-manager/mail.nix
      ../../2configs/home-manager/taskwarrior.nix

      ../../2configs/main-laptop.nix
      ../../2configs/kdeconnect.nix
      ../../2configs/extra-fonts.nix
      ../../2configs/editor/neovim
      ../../2configs/tools/all.nix
      { programs.adb.enable = true; }

      # secrets: now deployed once at host provisioning
      { state = [ "/etc/ssh/ssh_host_rsa_key" ]; }
      #{
      #  services.openssh.hostKeys = [
      #    { bits = 4096; path = (toString <secrets/ssh_host_rsa_key>); type = "rsa";}
      #  ];
      #}
      #{
      #  imports = [
      #    ../../2configs/bureautomation/rhasspy.nix
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
      # ../../2configs/dict.nix
      # ../../2configs/legacy_only.nix
      #../../3modules/netboot_server.nix
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
      ../../2configs/backup/state.nix

      # ../../2configs/dnscrypt/client.nix
      ../../2configs/avahi.nix
      ../../2configs/support-nixos.nix

      # Debugging
      # ../../2configs/disable_v6.nix
      # ../../2configs/pyload.nix

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
      # ../../2configs/deployment/gitlab.nix
      # ../../2configs/deployment/docker/etherpad.nix
      # ../../2configs/deployment/wiki-irc-bot

      # ../../2configs/torrent.nix
      # ../../2configs/deployment/dirctator.nix
      # ../../2configs/vncserver.nix
      # ../../2configs/deployment/led-fader
      # ../../2configs/deployment/hound
      # ../../2configs/deployment/photostore.krebsco.de.nix
      # ../../2configs/deployment/bureautomation/hass.nix
      # ../../2configs/bureautomation/office-radio

      # Krebs
      ../../2configs/tinc/retiolum.nix
      # ../../2configs/share/anon-ftp.nix
      # ../../2configs/share/anon-sftp.nix
      ../../2configs/share/gum-client.nix
      ../../2configs/share
      # ../../2configs/share/temp-share-samba.nix


      # applications
      # ../../2configs/exim-retiolum.nix
      ../../2configs/mail-client.nix
      ../../2configs/printer.nix
      # ../../2configs/syncthing.nix
      # ../../2configs/sync

      # Virtualization
      # ../../2configs/virtualisation/libvirt.nix
      ../../2configs/virtualisation/docker.nix
      ../../2configs/virtualisation/virtualbox.nix
      #{
      #  networking.firewall.allowedTCPPorts = [ 8080 ];
      #  networking.nat = {
      #    enable = true;
      #    externalInterface = "wlp3s0";
      #    internalInterfaces = [ "vboxnet0" ];
      #  };
      #}
      # Services
      ../../2configs/git/brain-retiolum.nix
      ../../2configs/tor.nix
      # ../../2configs/vpn/vpngate.nix
      # ../../2configs/buildbot-standalone.nix
      # ../../2configs/remote-build/aarch64-community.nix
      # ../../2configs/remote-build/gum.nix
      # { nixpkgs.overlays = [ (self: super: super.prefer-remote-fetch self super) ]; }

      # ../../2configs/binary-cache/gum.nix
      ../../2configs/binary-cache/lass.nix



      # Security
      # ../../2configs/sshd-totp.nix

      # temporary
      # { services.redis.enable = true; }
      # citadel exporter
      # { services.mongodb.enable = true; }
      # { services.elasticsearch.enable = true; }
      # ../../2configs/deployment/nixos.wiki
      # ../../2configs/home/photoprism.nix
      # ../../2configs/dcpp/airdcpp.nix
      # ../../2configs/nginx/rompr.nix
      # ../../2configs/lanparty/lancache.nix
      # ../../2configs/lanparty/lancache-dns.nix
      # ../../2configs/lanparty/samba.nix
      # ../../2configs/lanparty/mumble-server.nix
      ../../2configs/wireguard/wiregrill-client.nix

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
