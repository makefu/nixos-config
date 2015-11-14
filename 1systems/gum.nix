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

  ];

  krebs.build.target = "root@gum.krebsco.de";
  krebs.build.host = config.krebs.hosts.gum;

  # Chat
  environment.systemPackages = with pkgs;[
    weechat
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
  networking = {
  firewall = {
      allowPing = true;
      allowedTCPPorts = [
        # smtp
        25
        # http
        80 443
        # tinc
        655
      ];
      allowedUDPPorts = [
        # tinc
        655 53
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
