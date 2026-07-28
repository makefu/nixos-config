# Alerting stack for omo.
#
# Pipeline: exporters (blackbox / node-textfile) -> prometheus (scrape + rules)
# -> alertmanager (route) -> alertmanager-ntfy (webhook -> ntfy) ; karma is the
# human dashboard over alertmanager. All backends bind to loopback and are
# reached through nginx on *.euer (wireguard) and *.lan (local DNS).
#
# Adding a new alert = drop a file under ./checks/ that appends its own
# `services.prometheus.scrapeConfigs`, add its alert group to ./rules.nix (all
# rules live there in one entry — see ./rules.nix for why), and import the check
# here. No change to the core wiring below.
{ ... }:
{
  imports = [
    ./prometheus.nix
    ./rules.nix
    ./alertmanager.nix
    ./alertmanager-ntfy.nix
    ./karma.nix
    ./nginx.nix
    ./checks/web.nix
    ./checks/smb.nix
  ];
}
