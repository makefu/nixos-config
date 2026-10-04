# All prometheus alert rules, in a single services.prometheus.rules entry.
#
# They are collected here (not next to each check under ./checks/) because the
# module concatenates every .rules list entry into one file and keeps only the
# first group — so each check setting .rules on its own would silently drop all
# but one. Adding an alert = add a group to the list below.
#
# Failed units follow the mic92/eva pattern: one generic rule that fires on
# every unit node_exporter reports as failed, with a small blacklist of units
# whose failures are noise, not outages. There is no hand-maintained
# "critical units" list anymore: a service that was cleanly stopped and nobody
# noticed is not an outage, so it does not need an alert.
{
  services.prometheus.rules = [
    (builtins.toJSON {
      groups = [
        {
          name = "web";
          rules = [
            {
              alert = "WebServiceDown";
              expr = "probe_success{job=\"blackbox-http\"} == 0";
              for = "3m";
              labels.severity = "critical";
              annotations.summary = "{{ $labels.instance }} unreachable";
            }
          ];
        }
        {
          name = "smb";
          rules = [
            {
              alert = "SmbShareDown";
              expr = "smb_share_available == 0";
              for = "5m";
              labels.severity = "warning";
              annotations.summary = "SMB share //omo.lan/music/kinder unavailable";
            }
          ];
        }
        {
          name = "inference";
          rules = [
            {
              alert = "InferenceEndpointDown";
              expr = "probe_success{job=\"blackbox-bearer\"} == 0";
              for = "5m";
              labels.severity = "critical";
              # re-alerted every 24h while down (alertmanager route override,
              # see ./alertmanager.nix)
              annotations.summary = "inference.p0.contact not answering";
            }
          ];
        }
        {
          name = "systemd";
          rules = [
            {
              alert = "SystemdUnitFailed";
              # user@ instances are transient login sessions; a failed one is
              # a desktop nuisance, not a host outage. Label matchers take
              # RE2 inside a PromQL string, so the dot is escaped twice.
              expr = ''node_systemd_unit_state{name!~"user@[0-9]+\\.service",state="failed"} == 1'';
              for = "5m";
              labels.severity = "warning";
              annotations.summary = "{{ $labels.name }} failed on {{ $labels.instance }}";
            }
          ];
        }
        {
          name = "monitoring";
          rules = [
            {
              # without this the whole stack can go blind silently: no scrape, no
              # metric, no alert from any of the rules above
              alert = "PrometheusTargetDown";
              expr = "up == 0";
              for = "5m";
              labels.severity = "critical";
              annotations.summary = "scrape target {{ $labels.job }}/{{ $labels.instance }} down";
            }
          ];
        }
        {
          name = "disk";
          rules = [
            {
              # cryptroot btrfs rootfs (224G) has filled up before and broke
              # everything that writes to /tmp or /var/log. Fires from 95%
              # used; a 0-byte filesystem divides to NaN, which never fires.
              alert = "RootDiskAlmostFull";
              expr = ''(node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) < 0.05'';
              for = "10m";
              labels.severity = "warning";
              annotations.summary = "root disk on {{ $labels.instance }} at {{ printf \"%.1f\" (100 * (1 - $value)) }}% full";
            }
          ];
        }
      ];
    })
  ];
}
