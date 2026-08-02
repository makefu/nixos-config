{ lib, ... }:
{
  # Builders are forked by nix-daemon and inherit its scheduling params and
  # cgroup, so tuning the unit covers every build process.
  #
  # SCHED_IDLE: builds only get CPU when nothing else wants it. Right tradeoff
  # on an interactive laptop, where a stalled compositor is what gets noticed.
  nix.daemonCPUSchedPolicy = "idle";

  # Near no-op on x/t14: ionice needs BFQ but nvme0n1 runs `none`, and ZFS does
  # its own IO scheduling. Kept for hosts with a BFQ-backed non-ZFS store.
  nix.daemonIOSchedClass = "idle";
  nix.daemonIOSchedPriority = 7;

  # Weights only compare siblings under one cgroup parent, and nix-daemon sits
  # in system.slice while the desktop sits in user.slice — so weighting the
  # unit would not make it lose against the session. Own top-level slice does.
  systemd.slices.nix-build = {
    description = "Nix build processes";
    sliceConfig = {
      CPUWeight = 20; # system.slice / user.slice default to 100
      IOWeight = 20;
      # Throttle (not kill) builds before they evict the session and ZFS ARC.
      MemoryHigh = "16G";
    };
  };

  systemd.services.nix-daemon.serviceConfig = {
    Slice = "nix-build.slice";
    # Redundant under SCHED_IDLE (fixed weight, nice ignored), kept in case the
    # policy above is ever relaxed to `batch`.
    Nice = lib.mkForce 19;
  };
}
