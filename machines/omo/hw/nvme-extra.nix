{
  disko.devices = {
    disk = {
      datanvme = {
        type = "disk";
        device ="/dev/nvme0n1";
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
                mountOptions = [ "nofail" ];
              };
            }
          ];
        };
      };
    };
  };
}
