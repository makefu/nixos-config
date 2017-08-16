{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
let
  external-mac = "3a:66:48:8e:82:b2";
  external-ip = config.krebs.build.host.nets.internet.ip4.addr;
  external-ip6 = config.krebs.build.host.nets.internet.ip6.addr;
  external-gw = "188.68.40.1";
  external-gw6 = "fe80::1";
  external-netmask = 22;
  external-netmask6 = 64;
  ext-if = "et0"; # gets renamed on the fly
  internal-ip = config.krebs.build.host.nets.retiolum.ip4.addr;
  main-disk = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0-0-0-0";
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
      <stockholm/makefu/2configs/sabnzbd.nix>
      <stockholm/makefu/2configs/torrent.nix>
      <stockholm/makefu/2configs/iodined.nix>
      <stockholm/makefu/2configs/vpn/openvpn-server.nix>

      ## Web
      <stockholm/makefu/2configs/nginx/share-download.nix>
      <stockholm/makefu/2configs/nginx/euer.test.nix>
      <stockholm/makefu/2configs/nginx/euer.wiki.nix>
      <stockholm/makefu/2configs/nginx/euer.blog.nix>
      <stockholm/makefu/2configs/nginx/public_html.nix>
      <stockholm/makefu/2configs/nginx/update.connector.one.nix>

      <stockholm/makefu/2configs/deployment/mycube.connector.one.nix>
      <stockholm/makefu/2configs/deployment/graphs.nix>
      <stockholm/makefu/2configs/deployment/owncloud.nix>
      <stockholm/makefu/2configs/deployment/wiki-irc-bot>
      <stockholm/makefu/2configs/deployment/boot-euer.nix>
      <stockholm/makefu/2configs/deployment/hound>
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

  ];
  makefu.dl-dir = "/var/download";


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
