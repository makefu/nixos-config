{pkgs, ...}:

let
  cfgfile = pkgs.writeText "udpt-config" ''
    [db]
    driver=sqlite3
    param=:memory:

    [tracker]
    is_dynamic=yes
    port=6969
    threads=5
    allow_remotes=yes
    allow_iana_ips=no
    announce_interval=1800
    cleanup_interval=120

    [apiserver]
    enable=yes

    [logging]
    filename=-
    level=warning
  '';
in {
  makefu.udpt = {
    enable = true;
    inherit cfgfile;
  };

}
