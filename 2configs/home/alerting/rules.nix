# All prometheus alert rules, in a single services.prometheus.rules entry.
#
# They are collected here (not next to each check under ./checks/) because the
# module concatenates every .rules list entry into one file and keeps only the
# first group — so each check setting .rules on its own would silently drop all
# but one. Adding an alert = add a group to the list below.
{ ... }:
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
      ];
    })
  ];
}
