{ disks ? [ "/dev/sda" ], ... }: {
  disk = {
    x = {
      type = "disk";
      device = "/dev/sda";
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            name = "boot";
            type = "partition";
            start = "0";
            end = "1M";
            part-type = "primary";
            flags = ["bios_grub"];
          }
          {
            type = "partition";
            name = "ESP";
            start = "1M";
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
            type = "partition";
            name = "zfs";
            start = "512MiB";
            end = "100%";
            content = {
              type = "zfs";
              pool = "zroot";
            };
          }
        ];
      };
    };
  };
  zpool = {
    zroot = {
      type = "zpool";
      rootFsOptions.compression = "lz4";
      mountpoint = "/";

      datasets = {
        home = {
          zfs_type = "filesystem";
          mountpoint = "/home";
          options.mountpoint = "legacy";
        };
        reserved = {
          zfs_type = "filesystem";
          options.refreservation = "1G";
        };
      };
    };
  };
}
