# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  byid = dev: "/dev/disk/by-id/" + dev;
  keyFile = "/dev/disk/by-id/usb-Verbatim_STORE_N_GO_070B3CEE0B223954-0:0";
  rootDisk = byid "ata-INTEL_SSDSA2M080G2GC_CVPO003402PB080BGN";
  homePartition = byid "ata-INTEL_SSDSA2M080G2GC_CVPO003402PB080BGN-part3";
  # cryptsetup luksFormat $dev --cipher aes-xts-plain64 -s 512 -h sha512
  # cryptsetup luksAddKey $dev tmpkey
  # cryptsetup luksOpen $dev crypt0
  # mkfs.xfs /dev/mapper/crypt0 -L crypt0
  cryptDisk0 = byid "ata-ST2000DM001-1CH164_Z240XTT6";
  cryptDisk1 = byid "ata-TP02000GB_TPW151006050068";
  cryptDisk2 = byid "ata-WDC_WD20EARS-00MVWB0_WD-WCAZA5548487";
  # all physical disks
  allDisks = [ rootDisk cryptDisk0 cryptDisk1 cryptDisk2 ];
in {
  imports =
    [
      ../.
      # TODO: unlock home partition via ssh
      ../2configs/fs/single-partition-ext4.nix
      ../2configs/tinc-basic-retiolum.nix
      ../2configs/zsh-user.nix
      ../2configs/exim-retiolum.nix
      ../2configs/smart-monitor.nix
      ../2configs/mail-client.nix
      ../2configs/share-user-sftp.nix
      ../2configs/omo-share.nix
    ];
  networking.firewall.trustedInterfaces = [ "enp3s0" ];
  # udp:137 udp:138 tcp:445 tcp:139 - samba, allowed in local net
  # tcp:80          - nginx for sharing files
  # tcp:655 udp:655 - tinc
  # tcp:8080        - sabnzbd
  networking.firewall.allowedUDPPorts = [ 655 ];
  networking.firewall.allowedTCPPorts = [ 80 655 8080 ];

  # services.openssh.allowSFTP = false;
  krebs.build.source.nixpkgs.rev = "d0e3cca04edd5d1b3d61f188b4a5f61f35cdf1ce";

  # copy config from <secrets/sabnzbd.ini> to /var/lib/sabnzbd/
  services.sabnzbd.enable = true;
  systemd.services.sabnzbd.environment.SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

  # HDD Array stuff
  services.smartd.devices = builtins.map (x: { device = x; }) allDisks;

  makefu.snapraid = let
    toMapper = id: "/media/crypt${builtins.toString id}";
  in {
    enable = true;
    disks = map toMapper [ 0 1 ];
    parity = toMapper 2;
  };
  fileSystems = let
    cryptMount = name:
      { "/media/${name}" = { device = "/dev/mapper/${name}"; fsType = "xfs"; };};
  in {
    "/home" = {
      device = "/dev/mapper/home";
      fsType = "ext4";
    };
  } // cryptMount "crypt0"
    // cryptMount "crypt1"
    // cryptMount "crypt2";

  powerManagement.powerUpCommands = lib.concatStrings (map (disk: ''
      ${pkgs.hdparm}/sbin/hdparm -S 100 ${disk}
      ${pkgs.hdparm}/sbin/hdparm -B 127 ${disk}
      ${pkgs.hdparm}/sbin/hdparm -y ${disk}
    '') allDisks);

  # crypto unlocking
  boot = {
    initrd.luks = {
      devices = let
        usbkey = name: device: {
          inherit name device keyFile;
          keyFileSize = 4096;
        };
      in [
        (usbkey "home" homePartition)
        (usbkey "crypt0" cryptDisk0)
        (usbkey "crypt1" cryptDisk1)
        (usbkey "crypt2" cryptDisk2)
      ];
    };
    loader.grub.device = rootDisk;

    initrd.availableKernelModules = [
      "ahci"
      "ohci_pci"
      "ehci_pci"
      "pata_atiixp"
      "firewire_ohci"
      "usb_storage"
      "usbhid"
    ];

    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };

  hardware.enableAllFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;

  zramSwap.enable = true;
  zramSwap.numDevices = 2;

  krebs.build.host = config.krebs.hosts.omo;
}
