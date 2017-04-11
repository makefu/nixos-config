{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
let
  external-ip = config.krebs.build.host.nets.internet.ip4.addr;
  internal-ip = config.krebs.build.host.nets.retiolum.ip4.addr;
in {
  imports = [
      ../.
      ../2configs/headless.nix
      ../2configs/fs/simple-swap.nix
      ../2configs/fs/single-partition-ext4.nix
      ../2configs/smart-monitor.nix
      ../2configs/git/cgit-retiolum.nix
      ../2configs/backup.nix
      # ../2configs/mattermost-docker.nix
      ../2configs/disable_v6.nix
      ../2configs/exim-retiolum.nix
      ../2configs/tinc/retiolum.nix
      ../2configs/urlwatch.nix

      # services
      ../2configs/gum-share.nix
      ../2configs/sabnzbd.nix
      ../2configs/torrent.nix
      ../2configs/iodined.nix

      ## Web
      ../2configs/deployment/owncloud.nix
      ../2configs/nginx/share-download.nix
      ../2configs/nginx/euer.test.nix
      ../2configs/nginx/euer.wiki.nix
      ../2configs/nginx/euer.blog.nix
      ../2configs/nginx/public_html.nix
      ../2configs/nginx/update.connector.one.nix
      ../2configs/deployment/mycube.connector.one.nix
      ../2configs/deployment/graphs.nix

      # ../2configs/opentracker.nix
      ../2configs/logging/central-stats-client.nix
      ../2configs/logging/central-logging-client.nix

  ];
  services.smartd.devices = [ { device = "/dev/sda";} ];
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

  makefu.taskserver.enable = true;


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
  services.bitlbee.enable = true;
  systemd.services.bitlbee.environment.BITLBEE_DEBUG="1";
  # systemd.services.bitlbee.serviceConfig.ExecStart = "${pkgs.bitlbee}/bin/bitlbee -Dnv -c 

  # Hardware
  boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules = [ "pata_via" "uhci_hcd" ];
  boot.kernelModules = [ "kvm-intel" ];

  # Network
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ATTR{address}=="c8:0a:a9:c8:ee:dd", NAME="et0"
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
    interfaces.et0.ip4 = [{
      address = external-ip;
      prefixLength = 24;
    }];
    defaultGateway = "195.154.108.1";
    nameservers = [ "8.8.8.8" ];
  };

}
