# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  primaryInterface = config.makefu.server.primary-itf;
in {
  imports =
    [
      #./hw/omo.nix
      ./hw/tsp.nix
      <stockholm/makefu>
      <stockholm/makefu/2configs/zsh-user.nix>
      <stockholm/makefu/2configs/backup.nix>
      <stockholm/makefu/2configs/exim-retiolum.nix>
      # <stockholm/makefu/2configs/smart-monitor.nix>
      <stockholm/makefu/2configs/mail-client.nix>
      <stockholm/makefu/2configs/mosh.nix>
      <stockholm/makefu/2configs/tools/mobility.nix>
      # <stockholm/makefu/2configs/disable_v6.nix>
      #<stockholm/makefu/2configs/graphite-standalone.nix>
      #<stockholm/makefu/2configs/share-user-sftp.nix>
      <stockholm/makefu/2configs/share/omo.nix>
      # <stockholm/makefu/2configs/share/omo-timemachine.nix>
      <stockholm/makefu/2configs/tinc/retiolum.nix>


      # Logging
      #influx + grafana
      <stockholm/makefu/2configs/stats/server.nix>
      <stockholm/makefu/2configs/stats/nodisk-client.nix>
      # logs to influx
      <stockholm/makefu/2configs/stats/external/aralast.nix>
      <stockholm/makefu/2configs/stats/telegraf>
      <stockholm/makefu/2configs/stats/telegraf/europastats.nix>
      <stockholm/makefu/2configs/stats/arafetch.nix>

      # services
      <stockholm/makefu/2configs/syncthing.nix>
      <stockholm/makefu/2configs/mqtt.nix>
      <stockholm/makefu/2configs/remote-build/slave.nix>
      <stockholm/makefu/2configs/deployment/google-muell.nix>
      <stockholm/makefu/2configs/virtualisation/docker.nix>
      <stockholm/makefu/2configs/bluetooth-mpd.nix>
      <stockholm/makefu/2configs/deployment/homeautomation>
      {
        hardware.pulseaudio.systemWide = true;
        makefu.mpd.musicDirectory = "/media/cryptX/music";
      }


      # security
      <stockholm/makefu/2configs/sshd-totp.nix>
      # <stockholm/makefu/2configs/logging/central-logging-client.nix>

      <stockholm/makefu/2configs/torrent.nix>

      # <stockholm/makefu/2configs/elchos/search.nix>
      # <stockholm/makefu/2configs/elchos/log.nix>
      # <stockholm/makefu/2configs/elchos/irc-token.nix>

      ## as long as pyload is not in nixpkgs:
      # docker run -d -v /var/lib/pyload:/opt/pyload/pyload-config -v /media/crypt0/pyload:/opt/pyload/Downloads --name pyload --restart=always -p 8112:8000 -P writl/pyload

      # Temporary:
      # <stockholm/makefu/2configs/temp/rst-issue.nix>

    ];
  makefu.full-populate = true;
  krebs.rtorrent = {
    downloadDir = lib.mkForce "/media/cryptX/torrent";
    extraConfig = ''
      upload_rate = 200
    '';
  };
  users.groups.share = {
    gid = (import <stockholm/lib>).genid "share";
    members = [ "makefu" "misa" ];
  };
  networking.firewall.trustedInterfaces = [ primaryInterface ];

  # copy config from <secrets/sabnzbd.ini> to /var/lib/sabnzbd/
  services.sabnzbd.enable = true;
  systemd.services.sabnzbd.environment.SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

  makefu.ps3netsrv = {
    enable = true;
    servedir = "/media/cryptX/emu/ps3";
  };

  users.users.misa = {
    uid = 9002;
    name = "misa";
  };

  zramSwap.enable = true;

  krebs.Reaktor.reaktor-shack = {
    nickname = "Reaktor|shack";
    workdir = "/var/lib/Reaktor/shack";
    channels = [ "#shackspace" ];
    plugins = with pkgs.ReaktorPlugins;
    [ shack-correct
      # stockholm-issue
      sed-plugin
      random-emoji ];
  };
  krebs.Reaktor.reaktor-bgt = {
    nickname = "Reaktor|bgt";
    workdir = "/var/lib/Reaktor/bgt";
    channels = [ "#binaergewitter" ];
    plugins = with pkgs.ReaktorPlugins;
    [ titlebot
      # stockholm-issue
      nixos-version
      shack-correct
      sed-plugin
      random-emoji ];
  };

  krebs.build.host = config.krebs.hosts.omo;
}
