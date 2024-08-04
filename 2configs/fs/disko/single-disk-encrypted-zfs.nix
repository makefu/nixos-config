{ config,disk ? "/dev/nvme0n1", hostId, ... }: 
{
  services.zfs.autoScrub.enable = true;
  boot.zfs.requestEncryptionCredentials = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  networking.hostId = hostId;
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  # reduce ARC to 2GB
  boot.kernelParams = [ "zfs.zfs_arc_max=2884901888" ];

  disko.devices = {
    disk = {
      nvme = {
        type = "disk";
        device = disk;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512MiB";
              type = "EF00";
              priority = 1;
              # instead of "start" the priority is used, otherwise the partitions are created alphabetically (ESP before zfs)
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "tank";
              };
            };
          };
        };
      };
    };
    zpool = {
      tank = {
        type = "zpool";
        rootFsOptions = {
          compression = "lz4";
          #reservation = "5G";
          "com.sun:auto-snapshot" = "false";
        };
        mountpoint = null;
        postCreateHook = "zfs snapshot tank@blank";

        datasets = {
          
          root = {
            type = "zfs_fs";
            mountpoint = "/";
            options = {
              encryption = "aes-256-gcm";
              keyformat = "passphrase";
              "com.sun:auto-snapshot" = "true";
            };
            #keylocation = "file:///tmp/secret.key";
          };
          "root/home" = {
            type = "zfs_fs";
            mountpoint = "/home";
          };
        };
      };
    };
  };
}
