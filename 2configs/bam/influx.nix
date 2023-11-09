let
  collectd-port = 25826;
  influx-port = 8086;
  admin-port = 8083;
  grafana-port = 3000; # TODO nginx forward
  db = "collectd_db";
  logging-interface = "enp0s25";
in {
  networking.firewall.allowedTCPPorts = [ 3000 influx-port admin-port ];

  services.grafana.enable = true;
  services.grafana.settings.server.http_addr = "0.0.0.0";
  services.influxdb.enable = true;
  systemd.services.influxdb.serviceConfig.LimitNOFILE = 8192;

  services.influxdb.extraConfig = {
    meta.hostname = config.krebs.build.host.name;
    # meta.logging-enabled = true;
    http.bind-address = ":${toString influx-port}";
    admin.bind-address = ":${toString admin-port}";
    collectd = [{
      enabled = true;
      typesdb = "${pkgs.collectd}/share/collectd/types.db";
      database = db;
      bind-address = ":${toString collectd-port}";
    }];
  };

  networking.firewall.extraCommands = ''
    iptables -A INPUT -i ${logging-interface} -p tcp --dport ${toString grafana-port} -j ACCEPT
  '';
}