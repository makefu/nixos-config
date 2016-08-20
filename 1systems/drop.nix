{ config, pkgs, ... }:
let
  external-ip = "45.55.145.62";
  default-gw = "45.55.128.1";
  prefixLength = 18;
in {
  imports = [
      ../.
      ../2configs/hw/CAC.nix
      ../2configs/save-diskspace.nix
      ../2configs/torrent.nix
  ];
  krebs = {
    enable = true;
    tinc.retiolum.enable = true;
    build.host = config.krebs.hosts.drop;
  };

  boot.loader.grub.device = "/dev/vda";
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "ehci_pci" "virtio_pci" "virtio_blk" "virtio_net" "virtio_scsi" ];
  fileSystems."/" = {
    device = "/dev/vda1";
    fsType = "ext4";
  };

  networking = {
    firewall = {
      allowPing = true;
      logRefusedConnections = false;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ 655 ];
    };
    interfaces.enp0s3.ip4 = [{
      address = external-ip;
      inherit prefixLength;
    }];
    defaultGateway = default-gw;
    nameservers = [ "8.8.8.8" ];
  };
}
