{ config, lib, pkgs, ... }:

with pkgs.stockholm.lib;
let
  external-ip = config.krebs.build.host.nets.internet.ip4.addr;
  ext-if = config.makefu.server.primary-itf;
  allDisks = [ "/dev/sda" "/dev/sdb" ];
in {
  imports = [
      
      ../../2configs/networking/zerotier.nix
      ../../2configs/bam/grocy
      ./hetznercloud
      {
        # wait for mount
        systemd.services.rtorrent.wantedBy = lib.mkForce [];
        # systemd.services.phpfpm-nextcloud.wantedBy = lib.mkForce [];
        systemd.services.samba-smbd.wantedBy = lib.mkForce [];
      }
      #{
      #  users.users.lass = {
      #    uid = 19002;
      #    isNormalUser = true;
      #    createHome = true;
      #    useDefaultShell = true;
      #    openssh.authorizedKeys.keys = with config.krebs.users; [
      #      lass.pubkey
      #      makefu.pubkey
      #    ];
      #  };
      #}
      ../../2configs

      ../../2configs/nur.nix
      ../../2configs/support-nixos.nix
      ../../2configs/nix-community/supervision.nix
      ../../2configs/home-manager
      ../../2configs/home-manager/cli.nix
      # ../../2configs/stats/client.nix
      ../../2configs/share
      ../../2configs/share/hetzner-client.nix
      # ../../2configs/stats/netdata-server.nix

      # Security
      ../../2configs/sshd-totp.nix

      # Tools
      ../../2configs/tools/core.nix
      # ../../2configs/tools/dev.nix
      # ../../2configs/tools/sec.nix
      # ../../2configs/tools/desktop.nix

      ../../2configs/zsh
      ../../2configs/mosh.nix
      # ../../2configs/disable_v6.nix
      # ../../2configs/storj/forward-port.nix
      # ../../2configs/gui/xpra.nix

      # networking
      # ../../2configs/vpn/vpnws/server.nix
      #../../2configs/dnscrypt/server.nix
      ../../2configs/iodined.nix
      # ../../2configs/backup.nix
      ../../2configs/tinc/retiolum.nix
      { # bonus retiolum config for connecting more hosts
        krebs.tinc.retiolum = {
          #extraConfig = lib.mkForce ''
          #  ListenAddress = ${external-ip} 53
          #  ListenAddress = ${external-ip} 655
          #  ListenAddress = ${external-ip} 21031
          #  StrictSubnets = yes
          #  LocalDiscovery = no
          #'';
          connectTo = [
            "prism" "ni" "enklave" "eve" "dishfire"
          ];
        };
        networking.firewall = {
          allowedTCPPorts =
            [
            53
            655
            21031
          ];
          allowedUDPPorts =
          [
            53
            655
            21031
          ];
        };
      }

      # ci
      # ../../2configs/exim-retiolum.nix
      # ../../2configs/git/cgit-retiolum.nix
      ../../2configs/git/forgejo.nix


      ###### Shack #####
      # ../../2configs/shack/events-publisher
      # ../../2configs/shack/gitlab-runner


      # ../../2configs/deployment/buildbot/master.nix
      ../../2configs/deployment/atuin.nix

      # ../../2configs/remote-build/slave.nix
      # ../../2configs/remote-build/aarch64-community.nix
      ../../2configs/taskd.nix

      # services
      ../../2configs/bitlbee.nix # postgres backend
      # ../../2configs/sabnzbd.nix
      # ../../2configs/mail/mail.euer.nix
      # { krebs.exim.enable = mkDefault true; }
      ../../2configs/nix-community/mediawiki-matrix-bot.nix

      # sharing
      ../../2configs/share/gum.nix # samba sahre
      ../../2configs/torrent/rtorrent.nix
      # ../../2configs/sickbeard

      { nixpkgs.config.allowUnfree = true; }
      #../../2configs/retroshare.nix
      ## ../../2configs/ipfs.nix
      ../../2configs/sync
      ../../2configs/sync/relay.nix
      ../../2configs/sync/share/gum.nix
      # ../../2configs/opentracker.nix


      ## network
      # ../../2configs/vpn/openvpn-server.nix
      # ../../2configs/vpn/vpnws/server.nix
      # ../../2configs/binary-cache/server.nix
      { makefu.backup.server.repo = "/var/backup/borg"; }
      ../../2configs/backup/server.nix
      ../../2configs/backup/state.nix
      # ../../2configs/wireguard/server.nix
      ../../2configs/wireguard/wiregrill-server.nix

      { # recent changes mediawiki bot
        networking.firewall.allowedUDPPorts = [ 5005 5006 ];
      }
      # Removed until move: no extra mails
      # ../../2configs/urlwatch
      # Removed until move: avoid letsencrypt ban
      ### Web

      ../../2configs/bitwarden.nix # postgres backend
      ../../2configs/deployment/rss/rss.euer.krebsco.de.nix # postgres backend
      ../../2configs/deployment/rss/ratt.nix

      # ../../2configs/deployment/ntfysh.nix
      ../../2configs/deployment/nextcloud #postgres backend
      # ../../2configs/deployment/nextcloud/screeenly.nix

      # ../../2configs/deployment/buildbot/worker.nix
      ### Moving owncloud data dir to /media/cloud/nextcloud-data
      {
        users.users.nextcloud.extraGroups = [ "download" ];
        # nextcloud-setup fails as it cannot set permissions for nextcloud
        systemd.services.nextcloud-setup.serviceConfig.SuccessExitStatus = "0 1";
        systemd.tmpfiles.rules = [
          "L /var/lib/nextcloud/data - - - -  /media/cloud/nextcloud-data"
          "L /var/backup - - - -  /media/cloud/gum-backup"
        ];
        #fileSystems."/var/lib/nextcloud/data" = {
        #  device = "/media/cloud/nextcloud-data";
        #  options = [ "bind" ];
        #};
        #fileSystems."/var/backup" = {
        #  device = "/media/cloud/gum-backup";
        #  options = [ "bind" ];
        #};
      }

      ../../2configs/nginx/dl.euer.krebsco.de.nix
      #../../2configs/nginx/euer.test.nix
      ../../2configs/nginx/euer.mon.nix
      ../../2configs/nginx/euer.blog.nix
      ../../2configs/nginx/music.euer.nix
      ## ../../2configs/nginx/gum.krebsco.de.nix
      #../../2configs/nginx/public_html.nix
      #../../2configs/nginx/update.connector.one.nix
      ../../2configs/nginx/misa-felix-hochzeit.ml.nix
      # ../../2configs/nginx/gold.krebsco.de.nix
      # ../../2configs/nginx/iso.euer.nix

      # ../../2configs/deployment/photostore.krebsco.de.nix
      # ../../2configs/deployment/graphs.nix
      #../../2configs/deployment/owncloud.nix
      # ../../2configs/deployment/board.euer.krebsco.de.nix
      #../../2configs/deployment/feed.euer.krebsco.de
      # ../../2configs/deployment/boot-euer.nix
      ../../2configs/deployment/gecloudpad
      #../../2configs/deployment/docker/archiveteam-warrior.nix
      ../../2configs/deployment/mediengewitter.de.nix
      ../../2configs/bgt/etherpad.euer.krebsco.de.nix
      # ../../2configs/deployment/systemdultras-rss.nix

      ../../2configs/deployment/wiki.euer.nix

      ../../2configs/deployment/hoarder-proxy.nix
      ../../2configs/deployment/mdrss-proxy.nix
      ../../2configs/deployment/abook-proxy.nix
      #../../2configs/workadventure

      ../../2configs/bgt/download.binaergewitter.de.nix
      ../../2configs/bgt/hidden_service.nix
      ../../2configs/bgt/backup.nix
      # ../../2configs/bgt/social-to-irc.nix

      # ../../2configs/logging/client.nix

      # sharing
      # ../../2configs/dcpp/airdcpp.nix
      #{ krebs.airdcpp.dcpp.shares = {
      #    download.path = config.makefu.dl-dir + "/finished";
      #    sorted.path = config.makefu.dl-dir + "/sorted";
      #  };
      #}
      # ../../2configs/dcpp/hub.nix

      ## Temporary:
      # ../../2configs/temp/rst-issue.nix
      # ../../2configs/virtualisation/docker.nix
      #../../2configs/virtualisation/libvirt.nix

      # krebs infrastructure services
      # ../../2configs/stats/server.nix
    ];
  nixpkgs.config.permittedInsecurePackages = [ "olm-3.2.16" ];
  # makefu.dl-dir = "/var/download";
  makefu.dl-dir = "/media/cloud/download/finished";

  ###### stable

  krebs.build.host = config.krebs.hosts.gum;

  # Network
  networking = {
    firewall = {
        allowedTCPPorts = [
          80 443
          # 28967  # storj
        ];
        allowPing = true;
        logRefusedConnections = false;
    };
    nameservers = [ "8.8.8.8" ];
  };
  users.users.makefu.extraGroups = [ "download" "nginx" ];
  state = [ "/home/makefu/.weechat" ];
  clan.core.networking.targetHost = "root@gum.i";
}
