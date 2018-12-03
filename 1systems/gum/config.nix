{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
let
  external-ip = config.krebs.build.host.nets.internet.ip4.addr;
  ext-if = config.makefu.server.primary-itf;
  allDisks = [ "/dev/sda" "/dev/sdb" ];
in {
  imports = [
      <stockholm/makefu>
      ./hardware-config.nix
      {
        users.users.lass = {
          uid = 19002;
          isNormalUser = true;
          createHome = true;
          useDefaultShell = true;
          openssh.authorizedKeys.keys = with config.krebs.users; [
            lass.pubkey
            makefu.pubkey
          ];
        };
      }
      <stockholm/makefu/2configs/headless.nix>
      <stockholm/makefu/2configs/smart-monitor.nix>

      # Security
      <stockholm/makefu/2configs/sshd-totp.nix>

      # Tools
      <stockholm/makefu/2configs/tools/core.nix>
      <stockholm/makefu/2configs/tools/dev.nix>
      <stockholm/makefu/2configs/tools/sec.nix>
      <stockholm/makefu/2configs/zsh-user.nix>
      <stockholm/makefu/2configs/mosh.nix>
      # <stockholm/makefu/2configs/gui/xpra.nix>

      # networking
      <stockholm/makefu/2configs/vpn/openvpn-server.nix>
      # <stockholm/makefu/2configs/vpn/vpnws/server.nix>
      #<stockholm/makefu/2configs/dnscrypt/server.nix>
      <stockholm/makefu/2configs/iodined.nix>
      # <stockholm/makefu/2configs/backup.nix>
      <stockholm/makefu/2configs/tinc/retiolum.nix>

      # ci
      # <stockholm/makefu/2configs/exim-retiolum.nix>
      <stockholm/makefu/2configs/git/cgit-retiolum.nix>
      <stockholm/makefu/2configs/shack/gitlab-runner>
      <stockholm/makefu/2configs/remote-build/slave.nix>
      <stockholm/makefu/2configs/taskd.nix>

      # services
      <stockholm/makefu/2configs/sabnzbd.nix>
      <stockholm/makefu/2configs/mail/mail.euer.nix>

      # sharing
      <stockholm/makefu/2configs/share/gum.nix>
      <stockholm/makefu/2configs/torrent.nix>
      #<stockholm/makefu/2configs/retroshare.nix>
      ## <stockholm/makefu/2configs/ipfs.nix>
      #<stockholm/makefu/2configs/syncthing.nix>
      { # ncdc
        environment.systemPackages = [ pkgs.ncdc ];
        networking.firewall = {
          allowedUDPPorts = [ 51411 ];
          allowedTCPPorts = [ 51411 ];
        };
      }
      # <stockholm/makefu/2configs/opentracker.nix>

      ## network
      <stockholm/makefu/2configs/vpn/openvpn-server.nix>
      # <stockholm/makefu/2configs/vpn/vpnws/server.nix>
      <stockholm/makefu/2configs/dnscrypt/server.nix>
      <stockholm/makefu/2configs/binary-cache/server.nix>
      <stockholm/makefu/2configs/backup/server.nix>
      <stockholm/makefu/2configs/iodined.nix>
      <stockholm/makefu/2configs/bitlbee.nix>
      <stockholm/makefu/2configs/wireguard/server.nix>

      # Removed until move: no extra mails
      <stockholm/makefu/2configs/urlwatch>
      # Removed until move: avoid letsencrypt ban
      ### Web
      #<stockholm/makefu/2configs/nginx/share-download.nix>
      #<stockholm/makefu/2configs/nginx/euer.test.nix>
      <stockholm/makefu/2configs/nginx/euer.mon.nix>
      <stockholm/makefu/2configs/nginx/euer.wiki.nix>
      <stockholm/makefu/2configs/nginx/euer.blog.nix>
      ## <stockholm/makefu/2configs/nginx/gum.krebsco.de.nix>
      #<stockholm/makefu/2configs/nginx/public_html.nix>
      #<stockholm/makefu/2configs/nginx/update.connector.one.nix>
      <stockholm/makefu/2configs/nginx/misa-felix-hochzeit.ml.nix>
      <stockholm/makefu/2configs/nginx/gold.krebsco.de.nix>
      <stockholm/makefu/2configs/nginx/iso.euer.nix>
      <stockholm/krebs/2configs/cache.nsupdate.info.nix>
      <stockholm/makefu/2configs/shack/events-publisher>

      <stockholm/makefu/2configs/deployment/photostore.krebsco.de.nix>
      <stockholm/makefu/2configs/deployment/graphs.nix>
      <stockholm/makefu/2configs/deployment/owncloud.nix>
      <stockholm/makefu/2configs/deployment/boot-euer.nix>
      <stockholm/makefu/2configs/bgt/download.binaergewitter.de.nix>
      <stockholm/makefu/2configs/bgt/hidden_service.nix>

      <stockholm/makefu/2configs/stats/client.nix>
      # <stockholm/makefu/2configs/logging/client.nix>

      # sharing
      <stockholm/makefu/2configs/dcpp/airdcpp.nix>
      <stockholm/makefu/2configs/dcpp/hub.nix>

      ## Temporary:
      # <stockholm/makefu/2configs/temp/rst-issue.nix>
      <stockholm/makefu/2configs/virtualisation/docker.nix>
      <stockholm/makefu/2configs/virtualisation/libvirt.nix>

      # krebs infrastructure services
      <stockholm/makefu/2configs/stats/server.nix>
  ];
  makefu.dl-dir = "/var/download";

  services.openssh.hostKeys = [
    { bits = 4096; path = (toString <secrets/ssh_host_rsa_key>); type = "rsa"; }
    { path = (toString <secrets/ssh_host_ed25519_key>); type = "ed25519"; } ];
  ###### stable
  services.nginx.virtualHosts.cgit.serverAliases = [ "cgit.euer.krebsco.de" ];
  krebs.build.host = config.krebs.hosts.gum;

  krebs.tinc.retiolum = {
    extraConfig = ''
      ListenAddress = ${external-ip} 53
      ListenAddress = ${external-ip} 655
      ListenAddress = ${external-ip} 21031
    '';
    connectTo = [
      "prism" "ni" "enklave" "eve" "archprism"
    ];
  };


  # access
  users.users = {
    root.openssh.authorizedKeys.keys = [ config.krebs.users.makefu-omo.pubkey ];
    makefu.openssh.authorizedKeys.keys = [ config.krebs.users.makefu-vbob.pubkey config.krebs.users.makefu-bob.pubkey ];
  };

  # Chat
  environment.systemPackages = with pkgs;[
    weechat
    bepasty-client-cli
    tmux
  ];

  # Hardware

  # Network
  networking = {
    firewall = {
        allowPing = true;
        logRefusedConnections = false;
        allowedTCPPorts = [
          # smtp
          25
          # http
          80 443
          # httptunnel
          8080 8443
          # tinc
          655
          # tinc-shack
          21032
          # tinc-retiolum
          21031
          # taskserver
          53589
          # temp vnc
          18001
          # temp reverseshell
          31337
        ];
        allowedUDPPorts = [
          # tinc
          655 53
          # tinc-retiolum
          21031
          # tinc-shack
          21032
        ];
    };
    nameservers = [ "8.8.8.8" ];
  };
  users.users.makefu.extraGroups = [ "download" "nginx" ];
  services.smartd.devices = builtins.map (x: { device = x; }) allDisks;
  boot.tmpOnTmpfs = true;
  state = [ "/home/makefu/.weechat" ];
}
