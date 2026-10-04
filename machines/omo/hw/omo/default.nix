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
    # Data disks: shared key /etc/luks-keys/cryptroot + tang JWE
    # /etc/clevis/cryptroot.jwe (luks-disk.nix + README-omo-fde.md). Each volume
    # must carry cryptroot in a keyslot (luksFormat at install / luksAddKey).
    # nofail+headless: failed decrypt never breaks boot.
    (import ../luks-disk.nix {
      device = cryptDisk0;
      name = "crypt0";
      mountpoint = toMapper 0;
    })
    (import ../luks-disk.nix {
      device = cryptDisk1;
      name = "crypt1";
      mountpoint = toMapper 1;
    })
    (import ../luks-disk.nix {
      device = cryptDisk2;
      name = "crypt2";
      mountpoint = toMapper 2;
    })
    (import ../luks-disk.nix {
      device = cryptDisk3;
      name = "crypt3";
      mountpoint = toMapper 3;
    })
    # NVMe disks (/var/lib, /media/silent) stay plain xfs for now; encryption
    # later via the same luks-disk.nix tang scheme.
    ./nvme-extra.nix
  ];
  # Lock these mountpoints (chattr +i) at boot while their disk is absent so
  # services/tmpfiles fail with EPERM instead of writing stray trees onto the
  # rootfs that the later mount hides (see 3modules/media-unmounted-guard.nix).
  # /var/lib included: its nvme died once and everything under it silently
  # landed on the rootfs.
  makefu.mediaGuard.paths = [
    "/media/cloud"
    "/media/crypt0"
    "/media/crypt1"
    "/media/crypt2"
    "/media/crypt3"
    "/media/cryptX"
    "/media/silent"
    "/var/lib"
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

  # nixpkgs services.snapraid creates no state dir and no mount ordering:
  # sync failed with a snapraid NAMESPACE error once /var/lib/snapraid was
  # missing (it must live on the mounted /var/lib nvme, not the rootfs).
  systemd.tmpfiles.rules = [ "d /var/lib/snapraid 0700 root root - -" ];
  systemd.services.snapraid-sync.unitConfig.RequiresMountsFor = [
    "/var/lib"
    "/media/crypt0"
    "/media/crypt1"
    "/media/crypt2"
    "/media/crypt3"
  ];

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
          # mergerfs reads its source dirs at mount time; without these the
          # fuse mount could come up over empty crypt0-3 mountpoints (the
          # fstab generator does not know that the colon-separated device
          # paths are themselves mountpoints).
          "x-systemd.requires=media-crypt0.mount"
          "x-systemd.requires=media-crypt1.mount"
          "x-systemd.requires=media-crypt2.mount"
          "x-systemd.requires=media-crypt3.mount"
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
