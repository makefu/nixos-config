_:
{
  # do not swap that often
  boot.kernel.sysctl = {
    "vm.swappiness" = 25;
  };

  swapDevices = [
    { device = "/dev/disk/by-label/swap"; }
  ];
}
