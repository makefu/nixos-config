{ ... }: {
  #boot.loader.efi.canTouchEfiVariables = true;
  #boot.loader.systemd-boot.enable = true;
  #boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.enable = true;
  boot.loader.grub.copyKernels = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        # device = disk;
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            boot = { # required for embedding grub
              size = "1M";
              type = "EF02";
              priority = 1;
            };
            ESP = {
              name = "ESP";
              #start = "1M";
              type = "EF00";
              priority = 2;
              size = "1G";
              # bootable = true;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            swap = {
              size = "4G";
              #size = "100%";
              #end = "-4G";
              priority = 3;
              content = {
                type = "swap";
                priority = 1; # lowest prio
              };
            };
            root = {
              name = "root";
              priority = 4;
              #start = "1G";
              #end = "-4G";
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
