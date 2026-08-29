# Check: systemd unit health on omo.
# node_exporter's systemd collector exports node_systemd_unit_state per unit
# and state, plus per-service restart counters; prometheus scrapes the same
# node exporter as ./smb.nix and alerts on it (../rules.nix, group "systemd").
#
# Units are restricted to .service/.timer: the collector's default include
# regex is ".+", which adds a few thousand sockets/targets/paths worth of
# series for no alerting value.
{ ... }:
{
  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    listenAddress = "127.0.0.1";
    enabledCollectors = [ "systemd" ];
    extraFlags = [
      ''--collector.systemd.unit-include=.+\.(service|timer)''
      "--collector.systemd.enable-restarts-metrics"
    ];
  };
  # node exporter scrape job + textfile collector are declared in ./smb.nix
  # alert rules for this check live in ../rules.nix (group "systemd")
}
