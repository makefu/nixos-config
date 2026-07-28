# Alertmanager: single route, single receiver -> the alertmanager-ntfy bridge,
# which forwards to the ntfy server on gum.
{ ... }:
{
  services.prometheus.alertmanager = {
    enable = true;
    port = 9093;
    listenAddress = "127.0.0.1";
    # single node: disable the HA gossip listener, which otherwise binds
    # 0.0.0.0:9094 and collides with karma (see ./karma.nix)
    extraFlags = [ "--cluster.listen-address=" ];
    # used to build correct backlinks in notifications
    webExternalUrl = "http://alert.lan/";
    configuration = {
      route = {
        receiver = "ntfy";
        group_by = [ "alertname" ];
        group_wait = "30s";
        group_interval = "5m";
        repeat_interval = "4h";
      };
      receivers = [{
        name = "ntfy";
        webhook_configs = [{
          url = "http://127.0.0.1:9098/hook";
          send_resolved = true;
        }];
      }];
    };
  };
}
