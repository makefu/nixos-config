{pkgs, config, ...}:

with import <stockholm/lib>;
let
  irc-server = "irc.r";
  irc-nick = "m-alarm";
  collectd-port = 25826;
  influx-port = 8086;
  grafana-port = 3000;
  db = "collectd_db";
  logging-interface = config.makefu.server.primary-itf;
in {
  services.grafana.enable = true;
  services.grafana.addr = "0.0.0.0";

  services.influxdb.enable = true;
  systemd.services.influxdb.serviceConfig.LimitNOFILE = 8192;

  # redirect grafana to stats.makefu.r
  services.nginx.enable = true;
  services.nginx.virtualHosts."stats.makefu.r".locations."/".proxyPass = "http://localhost:3000";
  # forward these via nginx
  services.influxdb.extraConfig = {
    meta.hostname = config.krebs.build.host.name;
    # meta.logging-enabled = true;
    logging.level = "info";
    http.log-enabled = true;
    http.flux-enabled = true;
    http.write-tracing = false;
    http.suppress-write-log = true;
    data.trace-logging-enabled = false;
    data.query-log-enabled = false;
    reporting-disabled = true;

    http.bind-address = ":${toString influx-port}";
    admin.bind-address = ":8083";
    monitoring = {
      enabled = false;
      # write-interval = "24h";
    };
    collectd = [{
      enabled = true;
      typesdb = "${pkgs.collectd}/share/collectd/types.db";
      database = db;
      bind-address = ":${toString collectd-port}";
    }];
  };

  networking.firewall.extraCommands = ''
    iptables -A INPUT -i retiolum -p udp --dport ${toString collectd-port} -j ACCEPT
    iptables -A INPUT -i retiolum -p tcp --dport ${toString influx-port} -j ACCEPT
    iptables -A INPUT -i retiolum -p tcp --dport ${toString grafana-port} -j ACCEPT
    #iptables -A INPUT -i ${logging-interface} -p udp --dport ${toString collectd-port} -j ACCEPT
    #iptables -A INPUT -i ${logging-interface} -p tcp --dport ${toString influx-port} -j ACCEPT
    #iptables -A INPUT -i ${logging-interface} -p tcp --dport ${toString grafana-port} -j ACCEPT

    ip6tables -A INPUT -i retiolum -p udp --dport ${toString collectd-port} -j ACCEPT
    ip6tables -A INPUT -i retiolum -p tcp --dport ${toString influx-port} -j ACCEPT
    ip6tables -A INPUT -i retiolum -p tcp --dport ${toString grafana-port} -j ACCEPT
    #ip6tables -A INPUT -i ${logging-interface} -p udp --dport ${toString collectd-port} -j ACCEPT
    #ip6tables -A INPUT -i ${logging-interface} -p tcp --dport ${toString influx-port} -j ACCEPT
    #ip6tables -A INPUT -i ${logging-interface} -p tcp --dport ${toString grafana-port} -j ACCEPT
  '';
  state = [ "/var/lib/grafana/data/grafana.db" ];
}
