{ pkgs, lib, ... }:
let
  rapl = "/sys/class/powercap/intel-rapl:0";

  # i7-10610U is a 15 W part, but firmware programs PL1 = PL2 = 51 W. Fan off +
  # all-core build hits Tjmax, and the throttle drags the whole desktop with it.
  pl1Watt = 20;
  pl2Watt = 32;

  apply = pkgs.writeShellScript "intel-rapl-limits" ''
    set -eu
    echo ${toString (pl1Watt * 1000000)} > ${rapl}/constraint_0_power_limit_uw
    echo ${toString (pl2Watt * 1000000)} > ${rapl}/constraint_1_power_limit_uw
  '';
in
{
  # Firmware reprograms the limits across suspend, so re-apply on resume too.
  #systemd.services.intel-rapl-limits = {
  #  description = "Cap Intel package power limits (PL1/PL2)";
  #  wantedBy = [ "multi-user.target" ];
  #  unitConfig.ConditionPathExists = "${rapl}/constraint_0_power_limit_uw";
  #  serviceConfig = {
  #    Type = "oneshot";
  #    RemainAfterExit = true;
  #    ExecStart = apply;
  #  };
  #};

  #powerManagement.resumeCommands = "${apply}";

  ## nixos-hardware enables thermald, but it exits 30 ms after start and never
  ## managed anything. If it did run it would fight this module over PL1/PL2.
  #services.thermald.enable = lib.mkForce false;
}
