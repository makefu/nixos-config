{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
let
  # hw-specific
  external-mac = "2a:c5:6e:d2:fc:7f";
  main-disk = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0-0-0-0";
  external-gw = "185.194.140.1";
  # single partition, label "nixos"
  # cd /var/src; curl https://github.com/nixos/nixpkgs/tarball/809cf38 -L | tar zx ; mv * nixpkgs && touch .populate


  # static
  external-ip = config.krebs.build.host.nets.internet.ip4.addr;
  external-ip6 = config.krebs.build.host.nets.internet.ip6.addr;
  external-gw6 = "fe80::1";
  external-netmask = 22;
  external-netmask6 = 64;
  internal-ip = config.krebs.build.host.nets.retiolum.ip4.addr;
  ext-if = "et0"; # gets renamed on the fly
in {
  imports = [
      <stockholm/makefu>
      <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
      <stockholm/makefu/2configs/headless.nix>
      <stockholm/makefu/2configs/fs/single-partition-ext4.nix>
      # <stockholm/makefu/2configs/smart-monitor.nix>

      <stockholm/makefu/2configs/git/cgit-retiolum.nix>
      <stockholm/makefu/2configs/backup.nix>
      # <stockholm/makefu/2configs/mattermost-docker.nix>
      # <stockholm/makefu/2configs/disable_v6.nix>
      <stockholm/makefu/2configs/exim-retiolum.nix>
      <stockholm/makefu/2configs/tinc/retiolum.nix>
      <stockholm/makefu/2configs/urlwatch>

      # Security
      <stockholm/makefu/2configs/sshd-totp.nix>

      # Tools
      <stockholm/makefu/2configs/tools/core.nix>
      <stockholm/makefu/2configs/tools/dev.nix>
      <stockholm/makefu/2configs/tools/sec.nix>
      <stockholm/makefu/2configs/vim.nix>
      <stockholm/makefu/2configs/zsh-user.nix>

      # services
      <stockholm/makefu/2configs/share/gum.nix>
      # <stockholm/makefu/2configs/sabnzbd.nix>
      <stockholm/makefu/2configs/torrent.nix>
      <stockholm/makefu/2configs/mosh.nix>

      # network
      <stockholm/makefu/2configs/vpn/openvpn-server.nix>
      # <stockholm/makefu/2configs/vpn/vpnws/server.nix>
      <stockholm/makefu/2configs/dnscrypt/server.nix>
      <stockholm/makefu/2configs/iodined.nix>

      # buildbot
      <stockholm/makefu/2configs/remote-build/slave.nix>

      ## Web
      <stockholm/makefu/2configs/nginx/share-download.nix>
      <stockholm/makefu/2configs/nginx/euer.test.nix>
      <stockholm/makefu/2configs/nginx/euer.wiki.nix>
      <stockholm/makefu/2configs/nginx/euer.blog.nix>
      <stockholm/makefu/2configs/nginx/public_html.nix>
      <stockholm/makefu/2configs/nginx/update.connector.one.nix>

      <stockholm/makefu/2configs/deployment/photostore.krebsco.de.nix>
      <stockholm/makefu/2configs/deployment/graphs.nix>
      <stockholm/makefu/2configs/deployment/owncloud.nix>
      <stockholm/makefu/2configs/deployment/boot-euer.nix>
      <stockholm/makefu/2configs/deployment/bgt/hidden_service.nix>

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
      # <stockholm/makefu/2configs/ipfs.nix>
      <stockholm/makefu/2configs/syncthing.nix>

      # <stockholm/makefu/2configs/opentracker.nix>
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

  makefu.server.primary-itf = ext-if;

  # access
  users.users = {
    root.openssh.authorizedKeys.keys = [ config.krebs.users.makefu-omo.pubkey ];
    makefu.openssh.authorizedKeys.keys = [ config.krebs.users.makefu-vbob.pubkey config.krebs.users.makefu-bob.pubkey ];
  };

  # Chat
  environment.systemPackages = with pkgs;[
    weechat
    bepasty-client-cli
    get
  ];
  services.bitlbee = {
    enable = true;
    libpurple_plugins = [ pkgs.telegram-purple ];
  };

  # Hardware
  boot.loader.grub.device = main-disk;
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "sd_mod" "sr_mod" ];
  boot.kernelModules = [ "kvm-intel" ];

  # Network
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ATTR{address}=="${external-mac}", NAME="${ext-if}"
  '';
  boot.kernelParams = [ ];
  networking = {
    firewall = {
        allowPing = true;
        logRefusedConnections = false;
        allowedTCPPorts = [
          # smtp
          25
          # http
          80 443
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
    interfaces."${ext-if}" = {
      ip4 = [{
        address = external-ip;
        prefixLength = external-netmask;
      }];
      ip6 = [{
        address = external-ip6;
        prefixLength = external-netmask6;
      }];
    };
    defaultGateway6 = external-gw6;
    defaultGateway = external-gw;
    nameservers = [ "8.8.8.8" ];
  };

}
