{
  config,
  pkgs,
  lib,
  ...
}:
let
  toMapper = id: "/media/crypt${builtins.toString id}";
  byid = dev: "/dev/disk/by-id/" + dev;

  # mkfs.xfs -L cryptN /dev/mapper/cryptN
  # unlocked via disko luks-disk.nix (keyfile + clevis/tang), see README-omo-fde.md
  cryptDisk0 = byid "ata-ST8000DM004-2CX188_ZCT01PLV";
  cryptDisk1 = byid "ata-WDC_WD80EZAZ-11TDBA0_7SJPVLYW";
  cryptDisk3 = byid "ata-ST8000DM004-2CX188_ZCT01SG4";
  cryptDisk2 = byid "ata-WDC_WD80EZAZ-11TDBA0_7SJPWT5W";

  dataDisks = [
    cryptDisk0
    cryptDisk1
    cryptDisk2
    cryptDisk3
  ];
in
{
  imports = [
    ./vaapi.nix
    ../rootdisk.nix
    ./network.nix
    # early-ssh unlock disabled for now (module deleted from tree)
    # Data disks: create /etc/luks-keys/<name> + re-key each volume, then
    # uncomment (see README-omo-fde.md):
    # (import ../luks-disk.nix { device = cryptDisk0; name = "crypt0"; mountpoint = toMapper 0; })
    # (import ../luks-disk.nix { device = cryptDisk1; name = "crypt1"; mountpoint = toMapper 1; })
    # (import ../luks-disk.nix { device = cryptDisk2; name = "crypt2"; mountpoint = toMapper 2; })
    # (import ../luks-disk.nix { device = cryptDisk3; name = "crypt3"; mountpoint = toMapper 3; })
    # nvme disks move from plain xfs to LUKS the same way:
    # (import ../luks-disk.nix { device = byid "nvme-SAMSUNG_MZVLB256HBHQ-000L7_S4ELNX4N666803"; name = "varnvme"; mountpoint = "/var/lib"; })
    # (import ../luks-disk.nix { device = byid "nvme-SKHynix_HFS512GD9TNI-L2B0B_CS06N57461130743R"; name = "silent"; mountpoint = "/media/silent"; })
  ];

  # keep podman behind the data mounts (was in nvme-extra.nix)
  systemd.services.podman.after = [
    "var-lib.mount"
    "media-silent.mount"
  ];

  system.activationScripts.createCryptFolders = ''
    ${lib.concatMapStringsSep "\n" (d: "install -m 755 -d " + (toMapper d)) [
      0
      1
      2
      "X"
    ]}
  '';

  services.snapraid = {
    enable = true;
    dataDisks = {
      d0 = toMapper 0 + "/";
      d1 = toMapper 1 + "/";
      d3 = toMapper 3 + "/";
    };
    parityFiles = [ (toMapper 2 + "/snapraid.parity") ]; # find -name PARITY_PARTITION
    contentFiles =
      map (d: toMapper d + "/snapraid.content") [
        0
        1
        2
        3
      ]
      ++ [ "/var/lib/snapraid/snapraid.content" ];
    exclude = [
      "/lib/storj/"
      "/.bitcoin/blocks/"
    ];
    sync.interval = "03:42";
  };

  fileSystems =
    let
      cryptMount = name: {
        "/media/${name}" = {
          device = "/dev/mapper/${name}";
          fsType = "xfs";
          options = [ "nofail" ];
        };
      };
    in
    cryptMount "crypt0"
    // cryptMount "crypt1"
    // cryptMount "crypt2"
    // cryptMount "crypt3"
    // {
      "/media/cryptX" = {
        device = (
          lib.concatMapStringsSep ":" (d: (toMapper d)) [
            0
            1
            2
            3
          ]
        );
        fsType = "mergerfs";
        noCheck = true;
        options = [
          "defaults"
          "allow_other"
          "nofail"
          "nonempty"
        ];
      };
    };

  powerManagement.powerUpCommands = lib.concatStrings (
    map (disk: ''
      ${pkgs.hdparm}/sbin/hdparm -S 100 ${disk}
      ${pkgs.hdparm}/sbin/hdparm -B 127 ${disk}
      ${pkgs.hdparm}/sbin/hdparm -y ${disk}
    '') dataDisks
  );

  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  environment.systemPackages = with pkgs; [
    mergerfs # hard requirement for mount
  ];
  boot.kernelParams = [
    "fsck.mode=force"
    "fsck.repair=yes"
  ];
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;
}
