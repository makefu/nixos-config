{ config, pkgs, lib, ... }:
let
  toMapper = id: "/media/crypt${builtins.toString id}";
  byid = dev: "/dev/disk/by-id/" + dev;
  keyFile = byid "usb-Verbatim_STORE_N_GO_070B3CEE0B223954-0:0";
  rootDisk = byid "ata-SanDisk_SD8SNAT128G1122_162099420904";
  rootPartition = byid "ata-SanDisk_SD8SNAT128G1122_162099420904-part2";
  primaryInterface = "enp2s0";
  # cryptsetup luksFormat $dev --cipher aes-xts-plain64 -s 512 -h sha512
  # cryptsetup luksAddKey $dev tmpkey
  # cryptsetup luksOpen $dev crypt0 --key-file tmpkey --keyfile-size=4096
  # mkfs.xfs /dev/mapper/crypt0 -L crypt0

  # omo Chassis:
  # __FRONT_
  # |* d0   |
  # |       |
  # |* d1   |
  # |       |
  # |* d3   |
  # |       |
  # |*      |
  # |* d2   |
  # |  *    |
  # |  *    |
  # |_______|
  # cryptDisk0 = byid "ata-ST2000DM001-1CH164_Z240XTT6";
  cryptDisk0 = byid "ata-ST8000DM004-2CX188_ZCT01PLV";
  cryptDisk1 = byid "ata-TP02000GB_TPW151006050068";
  cryptDisk2 = byid "ata-ST4000DM000-1F2168_Z303HVSG";
  cryptDisk3 = byid "ata-ST8000DM004-2CX188_ZCT01SG4";
  # cryptDisk3 = byid "ata-WDC_WD20EARS-00MVWB0_WD-WMAZA1786907";
  # all physical disks

  # TODO callPackage ../3modules/MonitorDisks { disks = allDisks }
  dataDisks = [ cryptDisk0 cryptDisk1 cryptDisk2 cryptDisk3 ];
  allDisks = [ rootDisk ] ++ dataDisks;
in {
  imports =
    [ # TODO: unlock home partition via ssh
      <stockholm/makefu/2configs/fs/sda-crypto-root.nix> ];
  makefu.server.primary-itf = primaryInterface;
  system.activationScripts.createCryptFolders = ''
    ${lib.concatMapStringsSep "\n"
      (d: "install -m 755 -d " + (toMapper d) )
      [ 0 1 2 "X" ]}
  '';

  makefu.snapraid = {
    enable = true;
    # TODO: 3 is not protected
    disks = map toMapper [ 0 1 ];
    parity = toMapper 2;
  };
  fileSystems = let
    cryptMount = name:
      { "/media/${name}" = {
        device = "/dev/mapper/${name}"; fsType = "xfs";
        options = [ "nofail" ];
      };};
  in   cryptMount "crypt0"
    // cryptMount "crypt1"
    // cryptMount "crypt2"
    // cryptMount "crypt3"
    // { "/media/cryptX" = {
            device = (lib.concatMapStringsSep ":" (d: (toMapper d)) [ 0 1 2 3 ]);
            fsType = "mergerfs";
            noCheck = true;
            options = [ "defaults" "allow_other" "nofail" "nonempty" ];
          };
       };

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
          allowDiscards = true;
        };
      in [
        (usbkey "luksroot" rootPartition)
        (usbkey "crypt0" cryptDisk0)
        (usbkey "crypt1" cryptDisk1)
        (usbkey "crypt2" cryptDisk2)
        (usbkey "crypt3" cryptDisk3)
      ];
    };
    loader.grub.device = lib.mkForce rootDisk;

    initrd.availableKernelModules = [
      "ahci"
      "ohci_pci"
      "ehci_pci"
      "pata_atiixp"
      "firewire_ohci"
      "usb_storage"
      "usbhid"
    ];

    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };
  environment.systemPackages = with pkgs;[
    mergerfs # hard requirement for mount
  ];
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;
}

