# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  primaryInterface = config.makefu.server.primary-itf;
in {
  imports =
    [
      ./hw/omo.nix
      #./hw/tsp.nix
      ../../2configs/default.nix
      ../../2configs/support-nixos.nix
      ../../2configs/nur.nix
      {     
        systemd.coredump.extraConfig = ''
          Storage=none
          ProcessSizeMax=0
        '';
      }
      {
        services.xserver.enable = true;
        services.xserver.displayManager.sddm.enable = true;
        services.xserver.desktopManager.plasma5.enable = true;

        services.xrdp.enable = true;
        services.xrdp.defaultWindowManager = "startplasma-x11";
        services.xrdp.openFirewall = true;
      }
      # x11 forwarding
      {
        services.openssh.settings.X11Forwarding = true;
        users.users.makefu.packages = [
          pkgs.tinymediamanager
        ];
      }
      { environment.systemPackages = [ pkgs.youtube-dl2kodi pkgs.yt-dlp]; }

      ### systemdUltras ###
      ../../2configs/systemdultras/ircbot.nix

      ../../2configs/zsh
      ../../2configs/home-manager
      ../../2configs/home-manager/cli.nix
      ../../2configs/editor/neovim
      # ../../2configs/storj/client.nix

      #../../2configs/networking/zerotier.nix
      ../../2configs/backup/state.nix

      { makefu.backup.server.repo = "/media/cryptX/backup/borg"; }
      ../../2configs/backup/server.nix
      # ../../2configs/exim-retiolum.nix
      # ../../2configs/smart-monitor.nix
      ../../2configs/mail-client.nix
      ../../2configs/mosh.nix
      #../../2configs/nix-ld.nix
      ../../2configs/tools/core.nix
      ../../2configs/tools/dev.nix
      ../../2configs/tools/desktop.nix
      ../../2configs/tools/mobility.nix
      ../../2configs/tools/consoles.nix
      #../../2configs/graphite-standalone.nix
      #../../2configs/share-user-sftp.nix

      ../../2configs/urlwatch
      # ../../2configs/legacy_only.nix

      ../../2configs/share
      ../../2configs/share/omo.nix
      ../../2configs/share/hetzner-client.nix
      #../../2configs/share/gum-client.nix
      ../../2configs/sync
      ../../2configs/sync/omo-download-sync.nix
      ../../2configs/sync/share/omo.nix

      ../../2configs/wireguard/wiregrill-client.nix

      #  Community services
      ../../2configs/nix-community/legacy-mediawiki-matrix-bot.nix

      #../../2configs/dcpp/airdcpp.nix
      #{ krebs.airdcpp.dcpp.shares = let
      #    d = path: "/media/cryptX/${path}";
      #  in {
      #    emu.path = d "emu";
      #    audiobooks.path = lib.mkForce (d "audiobooks");
      #    incoming.path = lib.mkForce (d "torrent");
      #    anime.path = d "anime";
      #  };
      #  krebs.airdcpp.dcpp.DownloadDirectory = "/media/cryptX/torrent/dcpp";
      #}
      {
        # copy config from <secrets/sabnzbd.ini> to /var/lib/sabnzbd/
        #services.sabnzbd.enable = true;
        #systemd.services.sabnzbd.environment.SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      }
      # ../../2configs/share/omo-timemachine.nix
      ../../2configs/tinc/retiolum.nix

      # statistics
      # ../../2configs/stats/client.nix
      # Logging
      #influx + grafana
      ../../2configs/stats/server.nix
      # ../../2configs/stats/nodisk-client.nix
      # logs to influx
      ../../2configs/stats/external/aralast.nix
      # ../../2configs/stats/telegraf
      # ../../2configs/stats/telegraf/europastats.nix
      # ../../2configs/stats/telegraf/hamstats.nix
      ../../2configs/hw/cdrip.nix

      # services
      {
        services.nginx.enable = true;
        networking.firewall.allowedTCPPorts = [ 80 8123 ];
      }
      # ../../2configs/syncthing.nix
      ../../2configs/remote-build/slave.nix
      # TODO:
      ../../2configs/virtualisation/podman.nix
      # ../../2configs/bluetooth-mpd.nix

      ../../2configs/home/mdrss.nix
      ../../2configs/home/jellyfin.nix
      ../../2configs/home/music.nix
      ../../2configs/home/photoprism.nix
      ../../2configs/home/audiobookshelf.nix
      ../../2configs/home/komga.nix
      # ../../2configs/home/tonie.nix
      ../../2configs/home/ps4srv.nix
      ../../2configs/home/metube.nix
      # ../../2configs/home/ham
      ../../2configs/home/ham/docker.nix
      ../../2configs/home/zigbee/omo.nix
      ../../2configs/home/streams.nix
      ../../2configs/home/esphome.nix
      ../../2configs/home/audio-dl.nix
      ../../2configs/home/hoarder
      {
        makefu.ps3netsrv = {
          enable = true;
          servedir = "/media/cryptX/emu/ps3";
        };
        users.users.makefu.packages = [ pkgs.pkgrename ];
      }

      ../../2configs/home/paperless.nix

      #{
      #  hardware.pulseaudio.systemWide = true;
      #  makefu.mpd.musicDirectory = "/media/cryptX/music";
      #}

      # security
      ../../2configs/sshd-totp.nix
      # ../../2configs/logging/central-logging-client.nix

      # ../../2configs/torrent.nix
      {
        #krebs.rtorrent = {
        #  downloadDir = lib.mkForce "/media/cryptX/torrent";
        #  extraConfig = ''
        #    upload_rate = 500
        #  '';
        #};
      }

      # ../../2configs/elchos/search.nix
      # ../../2configs/elchos/log.nix
      # ../../2configs/elchos/irc-token.nix

      ## as long as pyload is not in nixpkgs:
      # docker run -d -v /var/lib/pyload:/opt/pyload/pyload-config -v /media/crypt0/pyload:/opt/pyload/Downloads --name pyload --restart=always -p 8112:8000 -P writl/pyload

      # Temporary:
      # ../../2configs/temp/rst-issue.nix
      # ../../2configs/bgt/social-to-irc.nix
      ../../2configs/bgt/nextcloud-chaptermark-hook.nix

    ];
  makefu.full-populate =  true;
  users.users.share.isNormalUser = true;
  users.groups.share = {
    gid = pkgs.stockholm.lib.genid "share";
    members = [ "makefu" "misa" ];
  };
  networking.firewall.trustedInterfaces = [ primaryInterface "docker0" ];



  users.users.misa = {
    uid = 9002;
    name = "misa";
    isNormalUser = true;
  };

  zramSwap.enable = true;

  #krebs.Reaktor.reaktor-shack = {
  #  nickname = "Reaktor|shack";
  #  workdir = "/var/lib/Reaktor/shack";
  #  channels = [ "#shackspace" ];
  #  plugins = with pkgs.ReaktorPlugins;
  #  [ shack-correct
  #    # stockholm-issue
  #    sed-plugin
  #    random-emoji ];
  #};
  #krebs.Reaktor.reaktor-bgt = {
  #  nickname = "Reaktor|bgt";
  #  workdir = "/var/lib/Reaktor/bgt";
  #  channels = [ "#binaergewitter" ];
  #  plugins = with pkgs.ReaktorPlugins;
  #  [ titlebot
  #    # stockholm-issue
  #    nixos-version
  #    shack-correct
  #    sed-plugin
  #    random-emoji ];
  #};
  krebs.build.host = config.krebs.hosts.omo;
  services.postgresql.package = pkgs.postgresql_15;
}
