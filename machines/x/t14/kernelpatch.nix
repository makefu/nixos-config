{
  boot.kernelPatches = [
  {
    name = "rtsx-pci-sdmmc-card-event-debug";
    patch = ./patches/rtsx-sdmmc-debug.patch;
  }
];
}
