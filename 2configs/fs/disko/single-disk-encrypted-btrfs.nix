{ disks ? [ "/dev/sda" ], ... }: {
  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-id/ata-SATA_SSD_8E3107640E0804179000";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name= "ESP";
              start = "1MiB";
              end = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                    };
                    "/home" = {
                      mountpoint = "/home";
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                    };
                    "/swap" = {
                      mountpoint = "/swapvol";
                      swap.swapfile.size = "17G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
