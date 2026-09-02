{ pkgs, lib, ... }:
let
  rapl = "/sys/class/powercap/intel-rapl:0";

  # i7-10610U is a 15 W part, but firmware programs PL1 = PL2 = 51 W. Measured
  # with an all-core load and the stock fan curve: 2.9 GHz, package at 84 C and
  # still climbing after 30 s. The cooler cannot carry 51 W, so the chip runs
  # into PROCHOT and the throttle drags the whole desktop with it.
  #
  # 25 W is roughly what the curve in fan.nix can hold. PL2 stays well above it
  # so short bursts (the window is ~2.4 ms) still feel instant.
  pl1Watt = 25;
  pl2Watt = 38;

  apply = pkgs.writeShellScript "intel-rapl-limits" ''
    set -eu
    echo ${toString (pl1Watt * 1000000)} > ${rapl}/constraint_0_power_limit_uw
    echo ${toString (pl2Watt * 1000000)} > ${rapl}/constraint_1_power_limit_uw
  '';
in
{
  systemd.services.intel-rapl-limits = {
    description = "Cap Intel package power limits (PL1/PL2)";
    unitConfig.ConditionPathExists = "${rapl}/constraint_0_power_limit_uw";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = apply;
    };
  };

  # Firmware reprograms both limits across suspend and every time
  # power-profiles-daemon flips /sys/firmware/acpi/platform_profile. sysfs has
  # no usable inotify, so re-assert on a timer rather than on an event.
  systemd.timers.intel-rapl-limits = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "10s";
      OnUnitActiveSec = "30s";
      AccuracySec = "5s";
    };
  };

  powerManagement.resumeCommands = "${apply}";

  # nixos-hardware enables thermald, but it exits right after start and never
  # manages anything. If it ever did run it would fight this module over
  # PL1/PL2 and fan.nix over the fan.
  services.thermald.enable = lib.mkForce false;
}
