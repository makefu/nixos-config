{ config, lib, pkgs, ... }:

# graphite-web on port 8080
# carbon cache on port 2003 (tcp/udp)
with lib;
let
  connect-time-cfg = with pkgs; writeText "collectd-connect-time.cfg" ''
    LoadPlugin python
    <Plugin python>
      ModulePath "${collectd-connect-time}/lib/${python.libPrefix}/site-packages/"
      Import "collectd_connect_time"
      <Module collectd_connect_time>
        target "wry.retiolum" "localhost" "google.com"
        interval 30
      </Module>
    </Plugin>
  '';
  graphite-cfg = pkgs.writeText "collectd-graphite-cfg" ''
    LoadPlugin write_graphite
    <Plugin "write_graphite">
      <Carbon>
        Host "heidi.retiolum"
        Port "2003"
        Prefix "retiolum."
        EscapeCharacter "_"
        StoreRates false
        AlwaysAppendDS false
      </Carbon>
    </Plugin>
  '';
in {
  imports = [ ];

  nixpkgs.config.packageOverrides = pkgs: with pkgs; {
    collectd = pkgs.collectd.override { python= pkgs.python; };
  };
  services.collectd = {
    enable = true;
    include = [ (toString connect-time-cfg) (toString graphite-cfg) ];
  };

}
