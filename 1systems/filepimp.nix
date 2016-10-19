{ config, pkgs, lib, ... }:
let
  byid = dev: "/dev/disk/by-id/" + dev;
  part1 = disk: disk + "-part1";
  rootDisk = byid "ata-SanDisk_SDSSDP064G_140237402890";
  primary-interface = "enp2s0"; # c8:cb:b8:cf:e4:dc
  # N54L Chassis:
  # ____________________
  # |______FRONT_______|
  # |   [             ]|
  # |   [ d1 ** d3 d4 ]|
  # |___[_____________]|
  jDisk1 = byid "ata-ST4000DM000-1F2168_Z3040NEA";

  # transfer to omo
  # jDisk0 = byid "ata-ST4000DM000-1F2168_Z303HVSG";
  jDisk2 = byid "ata-WDC_WD40EFRX-68WT0N0_WD-WCC4E0621363";
  jDisk3 = byid "ata-TOSHIBA_MD04ACA400_156GK89OFSBA";
  allDisks = [ rootDisk jDisk1 jDisk2 jDisk3 ];
in {
  imports =
    [ # Include the results of the hardware scan.
      ../.
      ../2configs/fs/single-partition-ext4.nix
      ../2configs/smart-monitor.nix
      ../2configs/tinc/retiolum.nix
      ../2configs/filepimp-share.nix
    ];

  krebs.build.host = config.krebs.hosts.filepimp;
  # AMD N54L
  boot = {
    loader.grub.device = rootDisk;

    initrd.availableKernelModules = [
      "ahci"
      "ohci_pci"
      "ehci_pci"
      "pata_atiixp"
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

  makefu.snapraid = let
    toMedia = name: "/media/" + name;
  in {
    enable = true;
    # todo combine creation when enabling the mount point
    disks = map toMedia [
                        # "j0"
                          "j1"
                          "j2"
                        ];
    parity = toMedia "par0";
  };
  # TODO: refactor, copy-paste from omo
  services.smartd.devices = builtins.map (x: { device = x; }) allDisks;
  powerManagement.powerUpCommands = lib.concatStrings (map (disk: ''
      ${pkgs.hdparm}/sbin/hdparm -S 100 ${disk}
      ${pkgs.hdparm}/sbin/hdparm -B 127 ${disk}
      ${pkgs.hdparm}/sbin/hdparm -y ${disk}
    '') allDisks);
  fileSystems = let
    xfsmount = name: dev:
      { "/media/${name}" = { device = dev; fsType = "xfs"; }; };
  in
  # (xfsmount "j0" (part1 jDisk0))   //
    (xfsmount "j1" (part1 jDisk1))   //
    (xfsmount "j2" (part1 jDisk2))   //
    (xfsmount "par0" (part1 jDisk3))
    ;

  networking.firewall.trustedInterfaces = [ primary-interface ];

  services.wakeonlan.interfaces = [
    {
      interface = primary-interface;
      method = "password";
      password = "CA:FE:BA:BE:13:37";
    }
  ];
}
