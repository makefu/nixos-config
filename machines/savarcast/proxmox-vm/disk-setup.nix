{ disks ? [ "/dev/sda" "/dev/sdb" ], ... }: {
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  swapDevices = [
    { device = "/dev/disk/by-uuid/5459dd33-a420-472f-b873-8a02d315b9ca"; }
  ];
  disko.devices = {
    disk = {
      main = {
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              name = "boot";
              size = "1M";
              type = "EF02";
            };
            ESP = {
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/";
              };
            };
          };
        };
      };
      storage = {
        device = "/dev/sdb";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            data = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/var/www";
              };
            };
          };
        };
      };
    };
  };
}
