{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
let
in {
  networking.firewall.allowedTCPPorts = [ 80 443 514 ];
  networking.firewall.allowedUDPPorts = [ 80 443 514 ];
	services.logstash = {
			enable = true;
			enableWeb = true;
      inputConfig = ''
				syslog {
          timezone => "Etc/UTC"
        }
      '';
      filterConfig = ''
        if ( [program] == "proftpd") {
          kv {
            field_split => "	"
          }
        }
      '';
      outputConfig = ''
        stdout {
          codec => rubydebug
        }
        elasticsearch { }
        '';
	};
	services.elasticsearch = {
			enable = true;
	};
	services.kibana = {
			enable = true;
      port = 9332;
	};
  services.nginx = {
    virtualHosts = {
      "log.nsupdate.info" = {
        enableACME = true;
        forceSSL = true;
        basicAuth = import <secrets/kibana-auth.nix>;
        locations = {
          "/" = {
            proxyPass = "http://localhost:9332";
            extraConfig = ''
              proxy_set_header   Host             $host;
              proxy_set_header   X-Real-IP        $remote_addr;
              proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
            '';
          };
        };
      };
    };
  };
}
