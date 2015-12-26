{ config, lib, pkgs, ... }:

with lib;
let
  external-ip = head config.krebs.build.host.nets.internet.addrs4;
  internal-ip = head config.krebs.build.host.nets.retiolum.addrs4;
in {
  imports = [
      # TODO: copy this config or move to krebs
      ../2configs/tinc-basic-retiolum.nix
      ../2configs/headless.nix
      ../2configs/fs/simple-swap.nix
      ../2configs/fs/single-partition-ext4.nix
      # ../2configs/iodined.nix
      ../2configs/git/cgit-retiolum.nix
      ../2configs/mattermost-docker.nix
      ../2configs/nginx/euer.test.nix

      ../2configs/exim-retiolum.nix
      ../2configs/urlwatch.nix
  ];


  nixpkgs.config.packageOverrides = pkgs: { tinc = pkgs.tinc_pre; };

  ###### stable
  krebs.build.target = "root@gum.krebsco.de";
  krebs.build.host = config.krebs.hosts.gum;
  krebs.retiolum.extraConfig = ''
    ListenAddress = ${external-ip} 53
    ListenAddress = ${external-ip} 655
    ListenAddress = ${external-ip} 21031
  '';

  # Chat
  environment.systemPackages = with pkgs;[
    weechat
    bepasty-client-cli
    get
  ];
  services.bitlbee.enable = true;

  # Hardware
  boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules = [ "pata_via" "uhci_hcd" ];
  boot.kernelModules = [ "kvm-intel" ];

  # Network
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ATTR{address}=="c8:0a:a9:c8:ee:dd", NAME="et0"
  '';
  boot.kernelParams = [ "ipv6.disable=1" ];
  networking = {
    enableIPv6 = false;
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
