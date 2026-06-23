{ pkgs, ... }:
{
  # powertop --auto-tune conflicts with power-profiles-daemon:
  # it overwrites EPP after ppd boot-apply and forces aggressive USB/SATA/audio
  # autosuspend that ppd does not manage. Keep powertop CLI available for
  # ad-hoc inspection but disable the auto-tune oneshot.
  powerManagement.powertop.enable = false;
  environment.systemPackages = [ pkgs.powertop ];

  # Comet Lake (client) does not auto-enable HWP dynamic boost — the kernel
  # restricts auto-enable to Skylake-server. Without it the CPU stays pinned
  # near the min P-state under bursty I/O (e.g. nix build + browser), causing
  # severe stutter even though max freq is 4.9 GHz. The kernel cmdline param
  # intel_pstate.hwp_dynamic_boost=1 is ignored on kernel 6.18 here, so force
  # it via sysfs at boot.
  boot.kernelParams = [ "intel_pstate.hwp_dynamic_boost=1" ];
  systemd.tmpfiles.rules = [
    "w /sys/devices/system/cpu/intel_pstate/hwp_dynamic_boost - - - - 1"
  ];

  # power-profiles-daemon 0.20+ has a "battery-aware" mode that picks EPP
  # `balance_power` (192) for the balanced profile on battery instead of
  # `balance_performance` (128). On this machine that drops responsiveness
  # below what "balanced" should mean. Disable it once at activation; ppd
  # persists the choice in /var/lib/power-profiles-daemon/state.ini.
  services.power-profiles-daemon.enable = true;
  systemd.services.ppd-disable-battery-aware = {
    description = "Disable power-profiles-daemon battery-aware EPP downgrade";
    requires = [ "power-profiles-daemon.service" ];
    after = [ "power-profiles-daemon.service" ];
    wantedBy = [ "power-profiles-daemon.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.power-profiles-daemon}/bin/powerprofilesctl configure-battery-aware --disable || true
    '';
  };

  users.users.makefu.packages = [ pkgs.gnome-power-manager ];
}
