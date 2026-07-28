# Check: three web services respond over HTTPS.
# blackbox_exporter runs the http_2xx probe; prometheus scrapes /probe per
# target and alerts when probe_success drops to 0.
{ pkgs, ... }:
{
  services.prometheus.exporters.blackbox = {
    enable = true;
    port = 9115;
    listenAddress = "127.0.0.1";
    configFile = pkgs.writeText "blackbox.yml" (builtins.toJSON {
      modules.http_2xx = {
        prober = "http";
        timeout = "10s";
        http = {
          method = "GET";
          fail_if_not_ssl = true;
          # empty -> default to 2xx
          valid_status_codes = [ ];
        };
      };
    });
  };

  services.prometheus.scrapeConfigs = [{
    job_name = "blackbox-http";
    metrics_path = "/probe";
    params.module = [ "http_2xx" ];
    static_configs = [{
      targets = [
        "https://blog.binaergewitter.de"
        "https://element.cybahn.de"
        "https://euer.krebsco.de"
      ];
    }];
    relabel_configs = [
      { source_labels = [ "__address__" ]; target_label = "__param_target"; }
      { source_labels = [ "__param_target" ]; target_label = "instance"; }
      { target_label = "__address__"; replacement = "127.0.0.1:9115"; }
    ];
  }];
  # alert rule for this check lives in ../rules.nix (WebServiceDown)
}
