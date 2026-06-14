
{ config, lib, ... }:

let
  device = "/dev/disk/by-id/ata-SATA_SSD_8E3107640E0804179000";
  hostId = "cafeb00b";
in
{
  services.zfs.autoScrub.enable = true;
  boot.zfs.requestEncryptionCredentials = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  boot.zfs.forceImportRoot = false;
  networking.hostId = hostId;
  # disable to fix zfs warning
  # boot.kernelPackages: using default linuxPackages (latestCompatibleLinuxPackages was deprecated)

  # reduce ARC to 4GB
  # rule of thumb:
  # 2GB Base + 1GB per TB Storage
  # https://pve.proxmox.com/pve-docs/pve-admin-guide.html#_limit_zfs_memory_usage
  boot.kernelParams = [ "zfs.zfs_arc_max=8589934592" ];

  disko.devices = {
    disk.main = {
      device = device;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "rpool";
            };
          };
        };
      };
    };

    zpool.rpool = {
      type = "zpool";

      options = {
        ashift = "12";
        autotrim = "on";
      };

      rootFsOptions = {
        compression = "zstd";
        acltype = "posixacl";
        xattr = "sa";
        canmount = "off";
        mountpoint = "none";
        "com.sun:auto-snapshot" = "true";
      };
      postCreateHook = "zfs snapshot rpool@blank";
      mountpoint = null;

      datasets = {
        "root" = {
          type = "zfs_fs";
          mountpoint = "/";
          options = {
            encryption = "aes-256-gcm";
            keyformat = "raw";
            keylocation = "file:///etc/zfs/zroot.key";
          };
        };

        "root/home" = {
          type = "zfs_fs";
          mountpoint = "/home";
        };

      };
    };
  };
}
