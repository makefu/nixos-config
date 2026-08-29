{ config, lib, pkgs, ... }:

with lib;
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
  services.grafana.settings.server.http_addr = "0.0.0.0";
  services.grafana.settings.security.secret_key = "herpderp";
  # the influxdb datasource logs every single dashboard query at debug level
  services.grafana.settings.log.level = "warn";
  # ... and the datasource backends do not honour that: they log through the
  # plugin SDK's hclog, which keeps emitting {"@level":"debug",...} lines
  # (verified by restarting grafana with level=warn in grafana.ini). Drop them
  # at the journal instead; warnings and errors use the same format but a
  # different @level and still get through.
  systemd.services.grafana.serviceConfig.LogFilterPatterns = [
    "~\"@level\":\"debug\""
  ];

  services.influxdb.enable = true;
  systemd.services.influxdb.serviceConfig.LimitNOFILE = 8192;

  # redirect grafana to stats.makefu.r
  services.nginx.enable = true;
  services.nginx.virtualHosts."stats.makefu.r" = {
    serverAliases = [ "graph.euer" ];
    locations."/".proxyPass = "http://localhost:3000";
  };
  networking.firewall.interfaces.euer.allowedTCPPorts = [ influx-port grafana-port collectd-port ];
  # forward these via nginx
  services.influxdb.dataDir = "/media/silent/db/influxdb";
  services.influxdb.extraConfig = {
    meta.hostname = config.clan.core.settings.machine.name;
    # meta.logging-enabled = true;
    logging.level = "info";
    # one apache-style line per grafana query, ~6k journal lines a day
    http.log-enabled = false;
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
  state = [ config.services.influxdb.dataDir ];
}
