{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
let
  external-ip = config.krebs.build.host.nets.internet.ip4.addr;
  ext-if = config.makefu.server.primary-itf;
in {
  imports = [
      <stockholm/makefu>
      ./hardware-config.nix
      ./transfer-config.nix
      <stockholm/makefu/2configs/headless.nix>
      # <stockholm/makefu/2configs/smart-monitor.nix>

      # Security
      <stockholm/makefu/2configs/sshd-totp.nix>

      # Tools
      <stockholm/makefu/2configs/tools/core.nix>
      <stockholm/makefu/2configs/tools/dev.nix>
      <stockholm/makefu/2configs/tools/sec.nix>
      <stockholm/makefu/2configs/zsh-user.nix>
      <stockholm/makefu/2configs/mosh.nix>
      <stockholm/makefu/2configs/gui/xpra.nix>

      <stockholm/makefu/2configs/git/cgit-retiolum.nix>
      <stockholm/makefu/2configs/backup.nix>
      <stockholm/makefu/2configs/exim-retiolum.nix>
      <stockholm/makefu/2configs/tinc/retiolum.nix>

      # services
      <stockholm/makefu/2configs/sabnzbd.nix>

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
      <stockholm/makefu/2configs/iodined.nix>
      <stockholm/makefu/2configs/bitlbee.nix>

      ## buildbot
      <stockholm/makefu/2configs/remote-build/slave.nix>

      # Removed until move: no extra mails
      <stockholm/makefu/2configs/urlwatch>
      # Removed until move: avoid double-update of domain
      # <stockholm/makefu/2configs/hub.nix>
      # Removed until move: avoid letsencrypt ban
      ### Web
      #<stockholm/makefu/2configs/nginx/share-download.nix>
      #<stockholm/makefu/2configs/nginx/euer.test.nix>
      #<stockholm/makefu/2configs/nginx/euer.mon.nix>
      #<stockholm/makefu/2configs/nginx/euer.wiki.nix>
      #<stockholm/makefu/2configs/nginx/euer.blog.nix>
      ## <stockholm/makefu/2configs/nginx/gum.krebsco.de.nix>
      #<stockholm/makefu/2configs/nginx/public_html.nix>
      #<stockholm/makefu/2configs/nginx/update.connector.one.nix>
      #<stockholm/makefu/2configs/nginx/misa-felix-hochzeit.ml.nix>
      <stockholm/makefu/2configs/nginx/gold.krebsco.de.nix>
      <stockholm/makefu/2configs/deployment/events-publisher>

      #<stockholm/makefu/2configs/deployment/photostore.krebsco.de.nix>
      #<stockholm/makefu/2configs/deployment/graphs.nix>
      #<stockholm/makefu/2configs/deployment/owncloud.nix>
      #<stockholm/makefu/2configs/deployment/boot-euer.nix>
      #<stockholm/makefu/2configs/deployment/bgt/hidden_service.nix>

      {
        services.taskserver.enable = true;
        services.taskserver.fqdn = config.krebs.build.host.name;
        services.taskserver.listenHost = "::";
        services.taskserver.organisations.home.users = [ "makefu" ];
        networking.firewall.extraCommands = ''
          iptables -A INPUT -i retiolum -p tcp --dport 53589 -j ACCEPT
          ip6tables -A INPUT -i retiolum -p tcp --dport 53589 -j ACCEPT
        '';
      }


      <stockholm/makefu/2configs/stats/client.nix>
      # <stockholm/makefu/2configs/logging/client.nix>

      ## Temporary:
      # <stockholm/makefu/2configs/temp/rst-issue.nix>
      <stockholm/makefu/2configs/virtualisation/docker.nix>
      <stockholm/makefu/2configs/virtualisation/libvirt.nix>

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
      { # wireguard server

        # opkg install wireguard luci-proto-wireguard

        # TODO: networking.nat

        # boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
        # conf.all.proxy_arp =1
        networking.firewall = {
          allowedUDPPorts = [ 51820 ];
          extraCommands = ''
            iptables -t nat -A POSTROUTING -s 10.244.0.0/24 -o ${ext-if} -j MASQUERADE
          '';
        };

        networking.wireguard.interfaces.wg0 = {
          ips = [ "10.244.0.1/24" ];
          listenPort = 51820;
          privateKeyFile = (toString <secrets>) + "/wireguard.key";
          allowedIPsAsRoutes = true;
          peers = [
          {
            # x
            allowedIPs = [ "10.244.0.2/32" ];
            publicKey = "fe5smvKVy5GAn7EV4w4tav6mqIAKhGWQotm7dRuRt1g=";
          }
          {
            # vbob
            allowedIPs = [ "10.244.0.3/32" ];
            publicKey = "Lju7EsCu1OWXhkhdNR7c/uiN60nr0TUPHQ+s8ULPQTw=";
          }
          {
            # x-test
            allowedIPs = [ "10.244.0.4/32" ];
            publicKey = "vZ/AJpfDLJyU3DzvYeW70l4FNziVgSTumA89wGHG7XY=";
          }
          {
            # work-router
            allowedIPs = [ "10.244.0.5/32" ];
            publicKey = "QJMwwYu/92koCASbHnR/vqe/rN00EV6/o7BGwLockDw=";
          }
          {
            # workr
            allowedIPs = [ "10.244.0.6/32" ];
            publicKey = "OFhCF56BrV9tjqW1sxqXEKH/GdqamUT1SqZYSADl5GA=";
          }
          ];
        };
      }
      { # iperf3
        networking.firewall.allowedUDPPorts = [ 5201 ];
        networking.firewall.allowedTCPPorts = [ 5201 ];
      }

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
  boot.tmpOnTmpfs = true;
}
