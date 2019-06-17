{ pkgs, lib, ... }:

with lib;
let
  port = 3001;
  runit = pkgs.writeDash "runit" ''
    set -xeuf
    PATH=${pkgs.mosquitto}/bin:${pkgs.coreutils}/bin
    name=''${1?must provide name as first arg}
    state=''${2?must provide state as second arg}
    # val=''${3?must provide val as third arg}

    # we ignore non-alerting events
    test $state = alerting || exit 0

    echo $name - $state
    topic=plug
    mosquitto_pub -t /bam/$topic/cmnd/POWER -m ON
    sleep 5
    mosquitto_pub -t /bam/$topic/cmnd/POWER -m OFF
  '';
in {
  imports = [
    ./ota.nix
  ];
  services.logstash = {
    package = pkgs.logstash7;
    plugins =  [ pkgs.logstash-output-exec ];
    enable = true;
    inputConfig = ''
       http {
        port => ${toString port}
        host => "127.0.0.1"
        type => "schlechteluft"
      }
    '';
    outputConfig = ''
      if [type] == "schlechteluft" {
        exec { command => "${runit} '%{ruleName}' '%{state}'" }
      }
    '';
  };
}
