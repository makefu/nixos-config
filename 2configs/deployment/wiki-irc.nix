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
            require "net/http"
            require "net/https"
            http = Net::HTTP.new("git.io", 443)
            http.use_ssl = true
            lines = []
            event["pages"].each {|p|
              url = "#{p["html_url"]}/_compare/#{p["sha"]}"
              short_url = begin
                request = Net::HTTP::Post.new "/"
                request.set_form_data ({"url" => url })
                response = http.request(request)
                response["location"]
              end
              lines << "\"#{p["title"]}\" #{p["action"]} by #{event["sender"]["login"]} #{short_url}"
            }
            event["output"] = lines.join("\n")
          '
        }
      }
    '';
    outputConfig = ''
      file { path => "/tmp/logs.json" codec => "json_lines" }
      if [output] {
        irc {
          channels => [ "#nixos" , "#krebs" ]
          host => "irc.freenode.net"
          nick => "nixos-users-wiki"
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
