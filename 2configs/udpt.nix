{pkgs, ...}:

let
  daemon-port = 6969;
  cfgfile = pkgs.writeText "udpt-config" ''
    [db]
    driver=sqlite3
    param=:memory:

    [tracker]
    is_dynamic=yes
    port=6969
    threads=5
    allow_remotes=yes

    # allow retiolum:
    allow_iana_ips=yes
    announce_interval=1800
    cleanup_interval=120

    [apiserver]
    enable=yes

    [logging]
    filename=/tmp/udpt.log
    level=warning
  '';
in {
  makefu.udpt = {
    enable = true;
    inherit cfgfile;
  };
  networking.firewall.extraCommands = ''
    iptables -A INPUT -i retiolum -p udp --dport ${toString daemon-port} -j ACCEPT
  '';

}
