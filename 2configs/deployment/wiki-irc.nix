{ pkgs, lib, ... }:

with lib;
let
  port = 18872;
in {
  services.logstash = {
    enable = true;
    inputConfig = ''
      http {
        port => ${toString port}
        host => "127.0.0.1"
      }
    '';
    filterConfig = ''
      if ([pages]) {
        ruby {
          code => '
            o = ""
            event["pages"].each { |p| o = o + "\"" + p["title"] + "\" " + p["action"] +" by "+ event["sender"]["login"]+" " +p["html_url"] + "/_compare/" + p["sha"] + "\n" }
            event["output"] = o
          '
        }
      }
    '';
    outputConfig = ''
      file { path => "/tmp/logs.json" codec => "json_lines" }
      if [output] {
        irc {
          channels => [ "#krebs" ]
          host => "irc.freenode.net"
          nick => "nixos-wiki"
          format => "%{output}"
        }
      }
    '';
    plugins = [ ];
  };

  services.nginx = {
    enable = lib.mkDefault true;
    virtualHosts."ghook.krebsco.de" = {
      locations."/".proxyPass = "http://localhost:${toString port}/";
      enableSSL = true;
      enableACME = true;
      forceSSL = true;
    };
  };
}
