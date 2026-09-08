# Check: the vLLM inference endpoint at inference.p0.contact answers
# authenticated requests.
#
# blackbox cannot take the token from the environment, so the http_bearer
# module in ../blackbox.nix carries it in the probe config, which is rendered
# at unit start from the sops secret (same token opencrow uses for this
# endpoint). /v1/models is the lightest authenticated vLLM call: it 200s when
# the engine is up and takes no inference time.
{ ... }:
{
  services.prometheus.scrapeConfigs = [{
    job_name = "blackbox-bearer";
    metrics_path = "/probe";
    params.module = [ "http_bearer" ];
    static_configs = [{
      targets = [ "https://inference.p0.contact/v1/models" ];
    }];
    relabel_configs = [
      { source_labels = [ "__address__" ]; target_label = "__param_target"; }
      { source_labels = [ "__param_target" ]; target_label = "instance"; }
      { target_label = "__address__"; replacement = "127.0.0.1:9115"; }
    ];
  }];
  # alert rule for this check lives in ../rules.nix (InferenceEndpointDown)
}
