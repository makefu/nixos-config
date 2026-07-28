# Prometheus core. Scrape targets live in the check modules (./checks/*.nix);
# alert rules live centrally in ./rules.nix (one services.prometheus.rules
# entry, because that option concatenates multiple entries into one document
# and keeps only the first group).
{ ... }:
{
  services.prometheus = {
    enable = true;
    port = 9090;
    listenAddress = "127.0.0.1";
    globalConfig.scrape_interval = "30s";
    # send firing alerts to the local alertmanager
    alertmanagers = [{
      static_configs = [{ targets = [ "127.0.0.1:9093" ]; }];
    }];
  };
}
