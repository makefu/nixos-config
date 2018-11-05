{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
let
  external-ip = config.krebs.build.host.nets.internet.ip4.addr;
  ext-if = config.makefu.server.primary-itf;
in {
  imports = [
      <stockholm/makefu>
      ./hardware-config.nix
      <stockholm/makefu/2configs/headless.nix>
      # <stockholm/makefu/2configs/smart-monitor.nix>

      <stockholm/makefu/2configs/git/cgit-retiolum.nix>
      <stockholm/makefu/2configs/backup/state.nix>
      # <stockholm/makefu/2configs/mattermost-docker.nix>
      # <stockholm/makefu/2configs/disable_v6.nix>
      <stockholm/makefu/2configs/exim-retiolum.nix>
      <stockholm/makefu/2configs/tinc/retiolum.nix>

      # Security
      <stockholm/makefu/2configs/sshd-totp.nix>

      # Tools
      <stockholm/makefu/2configs/tools/core.nix>
      <stockholm/makefu/2configs/tools/dev.nix>
      <stockholm/makefu/2configs/tools/sec.nix>
      <stockholm/makefu/2configs/zsh-user.nix>

      # services
      <stockholm/makefu/2configs/share/gum.nix>
      # <stockholm/makefu/2configs/sabnzbd.nix>
      <stockholm/makefu/2configs/torrent.nix>
      <stockholm/makefu/2configs/mosh.nix>
      # <stockholm/makefu/2configs/retroshare.nix>

      # network
      <stockholm/makefu/2configs/vpn/openvpn-server.nix>
      # <stockholm/makefu/2configs/vpn/vpnws/server.nix>
      <stockholm/makefu/2configs/dnscrypt/server.nix>
      <stockholm/makefu/2configs/iodined.nix>

      # buildbot
      <stockholm/makefu/2configs/remote-build/slave.nix>
      <stockholm/makefu/2configs/shack/gitlab-runner>

      ## Web
      #<stockholm/makefu/2configs/nginx/share-download.nix>
      #<stockholm/makefu/2configs/nginx/euer.test.nix>
      #<stockholm/makefu/2configs/nginx/euer.mon.nix>
      #<stockholm/makefu/2configs/nginx/euer.wiki.nix>
      #<stockholm/makefu/2configs/nginx/euer.blog.nix>
      ## <stockholm/makefu/2configs/nginx/gum.krebsco.de.nix>
      #<stockholm/makefu/2configs/nginx/public_html.nix>
      #<stockholm/makefu/2configs/nginx/update.connector.one.nix>
      #<stockholm/makefu/2configs/nginx/misa-felix-hochzeit.ml.nix>

      # <stockholm/makefu/2configs/deployment/photostore.krebsco.de.nix>
      # <stockholm/makefu/2configs/deployment/graphs.nix>
      # <stockholm/makefu/2configs/deployment/owncloud.nix>
      # <stockholm/makefu/2configs/deployment/boot-euer.nix>
      # <stockholm/makefu/2configs/deployment/bgt/hidden_service.nix>

      # <stockholm/makefu/2configs/ipfs.nix>
      # <stockholm/makefu/2configs/syncthing.nix>

      # <stockholm/makefu/2configs/opentracker.nix>
      <stockholm/makefu/2configs/dcpp/hub.nix>
      <stockholm/makefu/2configs/dcpp/airdcpp.nix>

      <stockholm/makefu/2configs/stats/client.nix>
      # <stockholm/makefu/2configs/logging/client.nix>

      # Temporary:
      # <stockholm/makefu/2configs/temp/rst-issue.nix>
      <stockholm/makefu/2configs/virtualisation/docker.nix>

      #{
      #  services.dockerRegistry.enable = true;
      #  networking.firewall.allowedTCPPorts = [ 8443 ];

      #  services.nginx.virtualHosts."euer.krebsco.de" = {
      #    forceSSL = true;
      #    enableACME = true;
      #    extraConfig = ''
      #      client_max_body_size 1000M;
      #    '';
      #    locations."/".proxyPass = "http://localhost:5000";
      #  };
      #}

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
      "muhbaasu" "tahoe" "flap" "wry"
      "ni"
      "fastpoke" "prism" "dishfire" "echelon" "cloudkrebs"
    ];
  };


  # access
  users.users = {
    root.openssh.authorizedKeys.keys = [ config.krebs.users.makefu-omo.pubkey ];
    makefu.openssh.authorizedKeys.keys = [ config.krebs.users.makefu-vbob.pubkey config.krebs.users.makefu-bob.pubkey ];
  };

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
  boot.tmpOnTmpfs = true;
}
