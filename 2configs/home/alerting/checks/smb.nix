# Check: SMB share //omo.lan/music/kinder is reachable.
# blackbox cannot speak SMB, so a timer probes it with smbclient (guest) and
# publishes smb_share_available through node_exporter's textfile collector;
# prometheus scrapes node_exporter and alerts on the metric.
{ pkgs, ... }:
let
  textfileDir = "/var/lib/node-exporter-textfile";
  smbCheck = pkgs.writeShellScript "smb-check" ''
    set -uo pipefail
    out="${textfileDir}/smb.prom"
    tmp="$out.$$"
    if ${pkgs.samba}/bin/smbclient -N //omo.lan/music -c 'cd kinder' >/dev/null 2>&1; then
      avail=1
    else
      avail=0
    fi
    {
      echo "# HELP smb_share_available SMB share reachable (1) or not (0)"
      echo "# TYPE smb_share_available gauge"
      echo "smb_share_available{share=\"music_kinder\",server=\"omo.lan\"} $avail"
    } > "$tmp"
    mv "$tmp" "$out"
  '';
in {
  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    listenAddress = "127.0.0.1";
    enabledCollectors = [ "textfile" ];
    extraFlags = [ "--collector.textfile.directory=${textfileDir}" ];
  };

  systemd.tmpfiles.rules = [ "d ${textfileDir} 0755 root root -" ];

  systemd.services.smb-check = {
    description = "Probe SMB share //omo.lan/music/kinder for node-exporter";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = smbCheck;
    };
  };
  systemd.timers.smb-check = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "2min";
      Unit = "smb-check.service";
    };
  };

  services.prometheus.scrapeConfigs = [{
    job_name = "node";
    static_configs = [{ targets = [ "127.0.0.1:9100" ]; }];
  }];
  # alert rule for this check lives in ../rules.nix (SmbShareDown)
}
