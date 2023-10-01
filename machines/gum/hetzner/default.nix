{ config, ... }:
let
  external-mac = "50:46:5d:9f:63:6b";
  main-disk = "/dev/disk/by-id/ata-TOSHIBA_DT01ACA300_13H8863AS";
  sec-disk = "/dev/disk/by-id/ata-TOSHIBA_DT01ACA300_23OJ2GJAS";
  external-gw = "144.76.26.225";
  # single partition, label "nixos"
  # cd /var/src; curl https://github.com/nixos/nixpkgs/tarball/809cf38 -L | tar zx ; mv * nixpkgs && touch .populate


  # static
  external-ip = "144.76.26.247";
  external-ip6 = "2a01:4f8:191:12f6::2";
  external-gw6 = "fe80::1";
  external-netmask = 27;
  external-netmask6 = 64;
  internal-ip = config.krebs.build.host.nets.retiolum.ip4.addr;
  ext-if = "et0"; # gets renamed on the fly
in {
  imports = [
      <stockholm/makefu/2configs/smart-monitor.nix>
      { services.smartd.devices = builtins.map (x: { device = x; }) allDisks; }

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
    defaultGateway6 = { address = external-gw6; interface = ext-if; };
    defaultGateway = external-gw;
  };
  boot.kernelParams = [ ];
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.devices = [ main-disk ];
  boot.initrd.kernelModules = [  "dm-raid" "dm_cache" "dm-thin-pool" ];
  boot.initrd.availableKernelModules = [
    "ata_piix" "vmw_pvscsi" "virtio_pci" "sd_mod" "ahci"
    "xhci_pci" "ehci_pci" "ahci" "sd_mod"
  ];
  boot.kernelModules = [ "dm-raid" "dm_cache" "dm-thin-pool" "kvm-intel"  ];
  hardware.enableRedistributableFirmware = true;
  fileSystems."/" = {
    device = "/dev/nixos/root";
    fsType = "ext4";
  };
  fileSystems."/var/lib" = {
    device = "/dev/nixos/lib";
    fsType = "ext4";
  };
  fileSystems."/var/log" = {
    device = "/dev/nixos/log";
    fsType = "ext4";
  };
  fileSystems."/var/download" = {
    device = "/dev/nixos/download";
    fsType = "ext4";
  };
  fileSystems."/var/www/binaergewitter" = {
    device = "/dev/nixos/binaergewitter";
    fsType = "ext4";
    options = [ "nofail" ];
  };
  fileSystems."/var/lib/nextcloud/data" = {
    device = "/dev/nixos/nextcloud";
    fsType = "ext4";
    options = [ "nofail" ];
  };
  fileSystems."/var/lib/borgbackup" = {
    device = "/dev/nixos/backup";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/sda2";
    fsType = "vfat";
  };
  # parted -s -a optimal "$disk" \
  #      mklabel gpt \
  #      mkpart no-fs 0 1024KiB \
  #      set 1 bios_grub on \
  #      mkpart ESP fat32 1025KiB 1024MiB  set 2 boot on \
  #      mkpart primary 1025MiB 100%
  # parted -s -a optimal "/dev/sdb" \
  #      mklabel gpt \
  #      mkpart primary 1M 100%

  #mkfs.vfat /dev/sda2
  #pvcreate /dev/sda3
  #pvcreate /dev/sdb1
  #vgcreate nixos /dev/sda3 /dev/sdb1
  #lvcreate -L 120G -m 1 -n root nixos
  #lvcreate -L 50G -m 1 -n lib nixos
  #lvcreate -L 100G -n download nixos
  #lvcreate -L 100G -n backup nixos
  #mkfs.ext4 /dev/mapper/nixos-root
  #mkfs.ext4 /dev/mapper/nixos-lib
  #mkfs.ext4 /dev/mapper/nixos-download
  #mkfs.ext4 /dev/mapper/nixos-borgbackup
  #mount /dev/mapper/nixos-root /mnt
  #mkdir /mnt/boot
  #mount /dev/sda2 /mnt/boot
  #mkdir -p /mnt/var/src
  #touch /mnt/var/src/.populate

}
