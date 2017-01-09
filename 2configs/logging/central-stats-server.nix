{pkgs, config, ...}:

with import <stockholm/lib>;
let
  collectd-port = 25826;
  influx-port = 8086;
  grafana-port = 3000; # TODO nginx forward
in {
  services.grafana.enable = true;
  services.grafana.addr = "0.0.0.0";

  services.influxdb.enable = true;

  # forward these via nginx
  services.influxdb.extraConfig = {
    meta.hostname = config.krebs.build.host.name;
    # meta.logging-enabled = true;
    http.bind-address = ":${toString influx-port}";
    admin.bind-address = ":8083";
    monitoring = {
      enabled = false;
      # write-interval = "24h";
    };
    collectd = [{
      enabled = true;
      typesdb = "${pkgs.collectd}/share/collectd/types.db";
      database = "collectd_db";
      port = collectd-port;
    }];
  };
  networking.firewall.extraCommands = ''
    iptables -A INPUT -i retiolum -p udp --dport ${toString collectd-port} -j ACCEPT
    iptables -A INPUT -i retiolum -p tcp --dport ${toString influx-port} -j ACCEPT
    iptables -A INPUT -i retiolum -p tcp --dport ${toString grafana-port} -j ACCEPT
  '';
}
