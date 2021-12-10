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
      <stockholm/makefu>
      <stockholm/makefu/2configs/headless.nix>
      <stockholm/makefu/2configs/support-nixos.nix>
      <stockholm/makefu/2configs/nur.nix>
      # x11 forwarding
      {
        services.openssh.forwardX11 = true;
        users.users.makefu.packages = [
          pkgs.tinymediamanager
        ];
      }
      { environment.systemPackages = [ pkgs.youtube-dl2kodi pkgs.youtube-dl]; }


      <stockholm/makefu/2configs/zsh-user.nix>
      <stockholm/makefu/2configs/home-manager>
      <stockholm/makefu/2configs/home-manager/cli.nix>
      <stockholm/makefu/2configs/editor/neovim>
      <stockholm/makefu/2configs/storj/client.nix>


      <stockholm/makefu/2configs/backup/state.nix>

      { makefu.backup.server.repo = "/media/cryptX/backup/borg"; }
      <stockholm/makefu/2configs/backup/server.nix>
      <stockholm/makefu/2configs/exim-retiolum.nix>
      # <stockholm/makefu/2configs/smart-monitor.nix>
      <stockholm/makefu/2configs/mail-client.nix>
      <stockholm/makefu/2configs/mosh.nix>
      <stockholm/makefu/2configs/tools/core.nix>
      <stockholm/makefu/2configs/tools/dev.nix>
      <stockholm/makefu/2configs/tools/desktop.nix>
      <stockholm/makefu/2configs/tools/mobility.nix>
      #<stockholm/makefu/2configs/graphite-standalone.nix>
      #<stockholm/makefu/2configs/share-user-sftp.nix>

      <stockholm/makefu/2configs/urlwatch>
      # <stockholm/makefu/2configs/legacy_only.nix>

      <stockholm/makefu/2configs/share/omo.nix>
      <stockholm/makefu/2configs/share/gum-client.nix>
      <stockholm/makefu/2configs/dcpp/airdcpp.nix>
      { krebs.airdcpp.dcpp.shares = let
          d = path: "/media/cryptX/${path}";
        in {
          emu.path = d "emu";
          audiobooks.path = lib.mkForce (d "audiobooks");
          incoming.path = lib.mkForce (d "torrent");
          anime.path = d "anime";
        };
        krebs.airdcpp.dcpp.DownloadDirectory = "/media/cryptX/torrent/dcpp";
      }
      {
        # copy config from <secrets/sabnzbd.ini> to /var/lib/sabnzbd/
        #services.sabnzbd.enable = true;
        #systemd.services.sabnzbd.environment.SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      }
      # <stockholm/makefu/2configs/share/omo-timemachine.nix>
      <stockholm/makefu/2configs/tinc/retiolum.nix>

      # statistics
      # <stockholm/makefu/2configs/stats/client.nix>
      # Logging
      #influx + grafana
      <stockholm/makefu/2configs/stats/server.nix>
      # <stockholm/makefu/2configs/stats/nodisk-client.nix>
      # logs to influx
      <stockholm/makefu/2configs/stats/external/aralast.nix>
      <stockholm/makefu/2configs/stats/telegraf>
      # <stockholm/makefu/2configs/stats/telegraf/europastats.nix>
      <stockholm/makefu/2configs/stats/telegraf/hamstats.nix>
      # <stockholm/makefu/2configs/stats/arafetch.nix>

      # services
      {
        services.nginx.enable = true;
        networking.firewall.allowedTCPPorts = [ 80 ];
      }
      # <stockholm/makefu/2configs/syncthing.nix>
      <stockholm/makefu/2configs/remote-build/slave.nix>
      # TODO:
      <stockholm/makefu/2configs/virtualisation/docker.nix>
      <stockholm/makefu/2configs/bluetooth-mpd.nix>

      <stockholm/makefu/2configs/home/music.nix>
      <stockholm/makefu/2configs/home/photoprism.nix>
      # <stockholm/makefu/2configs/home/metube.nix>
      <stockholm/makefu/2configs/home/ham>
      <stockholm/makefu/2configs/home/zigbee2mqtt>
      {
        makefu.ps3netsrv = {
          enable = true;
          servedir = "/media/cryptX/emu/ps3";
        };
      }


      {
        hardware.pulseaudio.systemWide = true;
        makefu.mpd.musicDirectory = "/media/cryptX/music";
      }

      # security
      <stockholm/makefu/2configs/sshd-totp.nix>
      # <stockholm/makefu/2configs/logging/central-logging-client.nix>

      # <stockholm/makefu/2configs/torrent.nix>
      {
        #krebs.rtorrent = {
        #  downloadDir = lib.mkForce "/media/cryptX/torrent";
        #  extraConfig = ''
        #    upload_rate = 500
        #  '';
        #};
      }

      # <stockholm/makefu/2configs/elchos/search.nix>
      # <stockholm/makefu/2configs/elchos/log.nix>
      # <stockholm/makefu/2configs/elchos/irc-token.nix>

      ## as long as pyload is not in nixpkgs:
      # docker run -d -v /var/lib/pyload:/opt/pyload/pyload-config -v /media/crypt0/pyload:/opt/pyload/Downloads --name pyload --restart=always -p 8112:8000 -P writl/pyload

      # Temporary:
      # <stockholm/makefu/2configs/temp/rst-issue.nix>
      <stockholm/makefu/2configs/bgt/social-to-irc.nix>

    ];
  makefu.full-populate =  true;
  nixpkgs.config.allowUnfree = true;
  users.users.share.isNormalUser = true;
  users.groups.share = {
    gid = (import <stockholm/lib>).genid "share";
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
}
