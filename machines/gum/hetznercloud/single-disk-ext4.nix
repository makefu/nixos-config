{ disk ? "/dev/sda", ... }: {
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  disko.devices = {
    disk = {
      disk1 = {
        device = disk;
        type = "disk";
        content = {
          type = "table";
          format = "gpt";
          partitions ={
            boot = {
              size = "1M";
              type = "EF02";
            };
            ESP = {
              name = "ESP";
              start = "1MiB";
              type = "EF00";
              end = "1G";
              bootable = true;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              name = "root";
              start = "500MiB";
              end = "-4G";
              part-type = "primary";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
            swap = {
              size = "4G";
              content = {
                type = "swap";
                priority = 1; # lowest prio
              };
            };
          };
        };
      };
    };
  };
}
