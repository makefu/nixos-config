# All prometheus alert rules, in a single services.prometheus.rules entry.
#
# They are collected here (not next to each check under ./checks/) because the
# module concatenates every .rules list entry into one file and keeps only the
# first group — so each check setting .rules on its own would silently drop all
# but one. Adding an alert = add a group to the list below.
{ lib, ... }:
let
  # Units whose absence is an outage, not a nuisance: they either serve
  # something on the network or hold state nobody notices going stale.
  # Everything else is covered by the generic SystemdUnitFailed rule; this list
  # exists because a cleanly *stopped* unit never enters state="failed".
  criticalUnits = [
    "nginx.service"
    "postgresql.service"
    "tincr-retiolum.service"
    "sshd.service"

    # media / library
    "jellyfin.service"
    "navidrome.service"
    "audiobookshelf.service"
    "komga.service"
    "photoprism.service"
    "minidlna.service"

    # documents / feeds / bookmarks
    "paperless-scheduler.service"
    "paperless-consumer.service"
    "paperless-task-queue.service"
    "redis-paperless.service"
    "karakeep-web.service"
    "karakeep-workers.service"
    "meilisearch.service"
    "changedetection-io.service"
    "podman-mdrss.service"
    "podman-mdrss-postgres.service"

    # home automation
    "container@hass.service"
    "container@hue.service"
    "zigbee2mqtt.service"
    "mosquitto.service"
    "esphome.service"

    # storage / sharing / backup
    "samba-smbd.service"
    "syncthing.service"
    "restic-rest-server.service"
    "container@kubo.service"
    "container@radicle.service"
    "container@torrent.service"

    # metrics + alerting itself
    "influxdb.service"
    "grafana.service"
    "prometheus.service"
    "alertmanager.service"
    "alertmanager-ntfy.service"
  ];
  # PromQL label matchers take RE2, so the dots have to be escaped or
  # "nginx.service" would also match e.g. "nginxXservice". The backslash is
  # doubled because the regex sits inside a PromQL string literal, where a lone
  # \. is rejected as an unknown escape sequence.
  criticalUnitsRe = lib.concatStringsSep "|"
    (map (lib.replaceStrings [ "." ] [ "\\\\." ]) criticalUnits);
in
{
  services.prometheus.rules = [
    (builtins.toJSON {
      groups = [
        {
          name = "web";
          rules = [{
            alert = "WebServiceDown";
            expr = "probe_success == 0";
            for = "3m";
            labels.severity = "critical";
            annotations.summary = "{{ $labels.instance }} unreachable";
          }];
        }
        {
          name = "smb";
          rules = [{
            alert = "SmbShareDown";
            expr = "smb_share_available == 0";
            for = "5m";
            labels.severity = "warning";
            annotations.summary = "SMB share //omo.lan/music/kinder unavailable";
          }];
        }
        {
          name = "systemd";
          rules = [
            {
              alert = "SystemdUnitFailed";
              expr = ''node_systemd_unit_state{state="failed"} == 1'';
              for = "5m";
              labels.severity = "warning";
              annotations.summary = "{{ $labels.name }} failed on {{ $labels.instance }}";
            }
            {
              alert = "SystemdCriticalUnitInactive";
              expr = ''node_systemd_unit_state{name=~"${criticalUnitsRe}",state="active"} == 0'';
              # deploys restart half of these; 10m is longer than any
              # switch-to-configuration run on omo
              for = "10m";
              labels.severity = "critical";
              annotations.summary = "{{ $labels.name }} not active on {{ $labels.instance }}";
            }
            {
              alert = "SystemdUnitRestartLoop";
              expr = ''changes(node_systemd_service_restart_total{name=~"${criticalUnitsRe}"}[30m]) > 3'';
              for = "5m";
              labels.severity = "warning";
              annotations.summary = "{{ $labels.name }} restarted repeatedly on {{ $labels.instance }}";
            }
          ];
        }
        {
          name = "monitoring";
          rules = [{
            # without this the whole stack can go blind silently: no scrape, no
            # metric, no alert from any of the rules above
            alert = "PrometheusTargetDown";
            expr = "up == 0";
            for = "5m";
            labels.severity = "critical";
            annotations.summary = "scrape target {{ $labels.job }}/{{ $labels.instance }} down";
          }];
        }
      ];
    })
  ];
}
