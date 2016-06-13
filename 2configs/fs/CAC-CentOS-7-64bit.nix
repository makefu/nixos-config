_:

{
  boot.loader.grub = {
    device = "/dev/sda";
  };
  fileSystems = {
    "/" = {
      device = "/dev/centos/root";
      fsType = "xfs";
    };
    "/boot" = {
      device = "/dev/sda1";
      fsType = "xfs";
    };
  };
  swapDevices = [
    { device = "/dev/centos/swap"; }
  ];
}
