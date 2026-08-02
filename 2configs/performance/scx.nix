{ ... }:
{
  # EEVDF shares CPU fairly but cannot tell that a task is on the critical path
  # of something a human is watching. lavd scores latency-criticality instead —
  # the video-playback-during-a-build case.
  #
  # lavd ignores cgroup cpu.weight (cpu.max only via experimental
  # --enable-cpu-bw), so build isolation rests on the cpuset and SCHED_IDLE
  # (weight 3, which lavd does read) — see performance/nix-performance.nix.
  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
    # Default mode anyway; spelled out because it also picks core compaction,
    # which matters on a package-power-capped U-series chip.
    extraArgs = [ "--autopilot" ];
  };
}
