{ ... }:
{
  # No swap at all meant every memory spike was resolved by evicting page cache
  # or by the OOM killer — both show up as a multi-second freeze.
  zramSwap = {
    enable = true;
    memoryPercent = 25; # ~7.5G of 30G, compressed
  };

  boot.kernel.sysctl = {
    # Default 60 is tuned for spinning rust; zram is RAM speed.
    "vm.swappiness" = 150;
    # Swap-in readahead is pointless when the device is RAM.
    "vm.page-cluster" = 0;
  };
}
