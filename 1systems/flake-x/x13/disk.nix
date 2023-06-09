{ disk ? "/dev/sda", ... }: {
  disko.devices = {
    disk = {
      nvme = {
        type = "disk";
        device = disk;
        content = {
          type = "table";
          format = "gpt";
          partitions = [
            {
              name = "ESP";
              start = "0";
              end = "512MiB";
              fs-type = "fat32";
              bootable = true;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            }
            {
              name = "zfs";
              start = "512MiB";
              end = "100%";
              content = {
                type = "zfs";
                pool = "tank";
              };
            }
          ];
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
