{
    systemd.services.podman.after = [ "var-lib.mount" "media-silent.mount" ];
  disko.devices = {
    disk = {
      varnvme = {
        type = "disk";
        device ="/dev/disk/by-id/nvme-SAMSUNG_MZVLB256HBHQ-000L7_S4ELNX4N666803";
        content = {
          type = "table";
          format = "gpt";
          partitions = [
            # mkfs.xfs -L varnvme /dev/nvme1n1p1
            {
              name = "varnvme";
              start = "0";
              end = "100%";
              content = {
                type ="filesystem";
                format = "xfs";
                mountpoint = "/var/lib";
              };
            }
          ];
        };
      };
      datanvme = {
        type = "disk";
        device ="/dev/disk/by-id/nvme-SKHynix_HFS512GD9TNI-L2B0B_CS06N57461130743R";
        content = {
          type = "table";
          format = "gpt";
          partitions = [
            {
              name = "silent";
              start = "0";
              end = "100%";
              content = {
                type ="filesystem";
                format = "xfs";
                mountpoint = "/media/silent";
              };
            }
          ];
        };
      };
    };
  };
}
