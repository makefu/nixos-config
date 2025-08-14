{ disks ? [ "/dev/sda" ], ... }: {
  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-diskseq/1";
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
              bootable = true;
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
