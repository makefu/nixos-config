{ config, pkgs, lib, ... }:

let
  byid = dev: "/dev/disk/by-id/" + dev;
  part1 = disk: disk + "-part1";
  rootDisk = byid "ata-SanDisk_SDSSDP064G_140237402890";
  primary-interface = "enp3s0"; # c8:cb:b8:cf:e4:dc
  # N54L Chassis:
  # ____________________
  # |______FRONT_______|
  # |   [             ]|
  # |   [ d1 d0 d3 d4 ]|
  # |___[_____________]|
  jDisk1 = byid "ata-ST4000DM000-1F2168_Z3040NEA";

  # transfer to omo
  jDisk0 = byid "ata-ST4000DM000-1F2168_Z303HVSG";
  jDisk2 = byid "ata-WDC_WD40EFRX-68WT0N0_WD-WCC4E0621363";
  jDisk3 = byid "ata-TOSHIBA_MD04ACA400_156GK89OFSBA";
  allDisks = [ rootDisk jDisk0 jDisk1 jDisk2 jDisk3 ];
in {
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
  makefu.server.primary-itf = primary-interface;

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;

  zramSwap.enable = true;

  makefu.snapraid = let
    toMedia = name: "/media/" + name;
  in {
    enable = true;
    # todo combine creation when enabling the mount point
    disks = map toMedia [
                          "j0"
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
      { "/media/${name}" = {
        device = dev; fsType = "xfs";
        options = [ "nofail" ];
      }; };
    tomedia = id: "/media/${id}";
  in
    (xfsmount "j0" (part1 jDisk0)) //
    (xfsmount "j1" (part1 jDisk1)) //
    (xfsmount "j2" (part1 jDisk2)) //
    (xfsmount "par0" (part1 jDisk3)) //
    { "/media/jX" = {
        device = (lib.concatMapStringsSep ":" (d: (tomedia d)) ["j0" "j1" "j2" ]);
        fsType = "mergerfs";
        noCheck = true;
        options = [ "defaults" "allow_other" "nofail" "nonempty" ];
      };
    };
  environment.systemPackages = [ pkgs.mergerfs ];
}
