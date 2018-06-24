{ config, ... }:
let
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
      <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
      <stockholm/makefu/2configs/fs/single-partition-ext4.nix>
  ];

  makefu.server.primary-itf = ext-if;
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ATTR{address}=="${external-mac}", NAME="${ext-if}"
  '';
  networking = {
    interfaces."${ext-if}" = {
      ipv4.addresses = [{
        address = external-ip;
        prefixLength = external-netmask;
      }];
      ipv6.addresses = [{
        address = external-ip6;
        prefixLength = external-netmask6;
      }];
    };
    defaultGateway6 = external-gw6;
    defaultGateway = external-gw;
  };
  boot.kernelParams = [ ];
  boot.loader.grub.device = main-disk;
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "sd_mod" "sr_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
}
