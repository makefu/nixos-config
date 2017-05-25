{pkgs, config, ...}:

with import <stockholm/lib>;
let
  es-port = 9200;
  kibana-port = 5601;
in {
  services.elasticsearch = {
    enable = true;
    listenAddress = "0.0.0.0";
    port = es-port;
  };
  services.kibana = {
    enable = true;
    listenAddress = "0.0.0.0";
    port = kibana-port;
  };

  networking.firewall.extraCommands = ''
    iptables -A INPUT -i retiolum -p tcp --dport ${toString es-port} -j ACCEPT
    iptables -A INPUT -i retiolum -p tcp --dport ${toString kibana-port} -j ACCEPT
  '';
}
