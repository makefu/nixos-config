{pkgs, config, ...}:

with import <stockholm/lib>;
let
  collectd-port = 25826;
  influx-port = 8086;
  grafana-port = 3000; # TODO nginx forward
  db = "collectd_db";
  logging-interface = config.makefu.server.primary-itf;
in {
  services.grafana.enable = true;
  services.grafana.addr = "0.0.0.0";

  services.influxdb.enable = true;
  # redirect grafana to stats.makefu.r
  services.nginx.enable = true;
  services.nginx.virtualHosts."stats.makefu.r".locations."/".proxyPass = "http://localhost:3000";
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
      database = db;
      bind-address = ":${toString collectd-port}";
    }];
  };
  krebs.kapacitor =
   let
      echoToIrc = pkgs.writeDash "echo_irc" ''
        set -euf
        data="$(${pkgs.jq}/bin/jq -r .message)"
        export LOGNAME=malarm
        ${pkgs.irc-announce}/bin/irc-announce \
          irc.freenode.org 6667 malarm \#krebs-bots "$data" >/dev/null
      '';
  in {
    enable = true;
    alarms = {
      cpu_deadman.database = db;
      cpu_deadman.text = ''
        var data = batch
            |query(${"'''"}
                  SELECT mean("value") AS mean
                  FROM "collectd_db"."default"."cpu_value"
                  WHERE "type_instance" = 'idle' AND "type" = 'percent' fill(0)
                ${"'''"})
                .period(10m)
                .every(1m)
                .groupBy('host')
        data |alert()
                .crit(lambda: "mean" < 50)
                .stateChangesOnly()
                .exec('${echoToIrc}')
        data |deadman(1.0,5m)
                .stateChangesOnly()
                .exec('${echoToIrc}')
      '';
    };

  };
  networking.firewall.extraCommands = ''
    iptables -A INPUT -i retiolum -p udp --dport ${toString collectd-port} -j ACCEPT
    iptables -A INPUT -i retiolum -p tcp --dport ${toString influx-port} -j ACCEPT
    iptables -A INPUT -i retiolum -p tcp --dport ${toString grafana-port} -j ACCEPT
    iptables -A INPUT -i ${logging-interface} -p udp --dport ${toString collectd-port} -j ACCEPT
    iptables -A INPUT -i ${logging-interface} -p tcp --dport ${toString influx-port} -j ACCEPT
    iptables -A INPUT -i ${logging-interface} -p tcp --dport ${toString grafana-port} -j ACCEPT

    ip6tables -A INPUT -i retiolum -p udp --dport ${toString collectd-port} -j ACCEPT
    ip6tables -A INPUT -i retiolum -p tcp --dport ${toString influx-port} -j ACCEPT
    ip6tables -A INPUT -i retiolum -p tcp --dport ${toString grafana-port} -j ACCEPT
    ip6tables -A INPUT -i ${logging-interface} -p udp --dport ${toString collectd-port} -j ACCEPT
    ip6tables -A INPUT -i ${logging-interface} -p tcp --dport ${toString influx-port} -j ACCEPT
    ip6tables -A INPUT -i ${logging-interface} -p tcp --dport ${toString grafana-port} -j ACCEPT
  '';
}
