{ pkgs, lib, ... }:

with lib;
let
  port = 18872;
  runit = pkgs.writeDash "runit" ''
    set -xeuf
    export PULSE_COOKIE=/var/run/pulse/.config/pulse/cookie
    echo "$@" | sed 's/^dirctator://' | ${pkgs.espeak}/bin/espeak -v mb-de7 2>&1 | tee -a /tmp/speak
  '';
in {
  services.logstash = {
    enable = true;
    inputConfig = ''
      irc {
        channels => [ "#krebs", "#afra" ]
        host => "irc.freenode.net"
        nick => "dirctator"
      }
    '';
    filterConfig = ''
    '';
    outputConfig = ''
      stdout { codec => rubydebug }
      exec { command => "${runit} '%{message}" }
    '';
    plugins = [ ];
  };
}
