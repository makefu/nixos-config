{pkgs, config, ...}:

let
  es-port = 9200;
  kibana-port = 5601;
  primaryName = "log.${config.krebs.build.host.name}";
  serverAliases = [ "${primaryName}.r" "${primaryName}.lan" ];
in {

  services.nginx.virtualHosts.${primaryName} = {
    inherit serverAliases;
    locations."/" =  {
      proxyPass = "http://localhost:5601/";
      extraConfig = ''
          proxy_set_header   Host $host;
          proxy_set_header   X-Real-IP          $remote_addr;
          proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };
  };
  services.elasticsearch = {
    enable = true;
    port = es-port;
  };
  services.kibana = {
    enable = true;
    port = kibana-port;
  };

  networking.firewall.extraCommands = ''
    iptables -A INPUT -i retiolum -p tcp --dport ${toString es-port} -j ACCEPT
    iptables -A INPUT -i retiolum -p tcp --dport ${toString kibana-port} -j ACCEPT
  '';

  # send logs directly to elasticsearch
  services.journalbeat = {
    enable = true;
    package = pkgs.journalbeat7;
    extraConfig = ''
      logging:
        to_syslog: true
        level: info
        metrics.enabled: false
        template.enabled: false
      output.logstash:
        hosts: [ "127.0.0.1:5044" ]
        template.enabled: false
        index: journalbeat
      journalbeat.inputs:
      - paths: []
        seek: cursor
    '';
  };

  services.logstash = {
    enable = true;
    # package = pkgs.logstash5;
    # plugins = [ pkgs.logstash-contrib ];
    inputConfig =
    ''
      syslog {
        timezone => "Etc/UTC"
      }
      beats {
        port => 5044
      }
    '';
    filterConfig =
    ''
      # Assume Beats
      if [syslog] {
        mutate {
          add_field => { "program" => "%{[syslog][identifier]}" }
        }
      }
    '' +
    ''
    if ![program] {
      mutate {
        add_field => { "program" => "unknown" }
      }
    }
    '' +
    ''
      if ([program] == "logstash") {
        drop {}
      }
    '' +
    ''
    if ( [program] == "dnsmasq") {
        grok {
            patterns_dir => ["${./patterns}"]
            match => {
              "message" => [
                  "^%{DNSID:dnsid} %{IP:client}/%{PORT} %{DNSRESPONSE:dnstype}\[[\w]+\] %{DOMAIN:domain} from %{IP}"
                , "^%{DNSID:dnsid} %{IP:client}/%{PORT} %{DNSRESPONSE:dnstype} %{DOMAIN:domain} is %{IPORWORD:resolved_ip}"
                , "^%{DNSID:dnsid} %{IP:client}/%{PORT} %{DNSRESPONSE:dnstype} %{DOMAIN:domain} to %{IP:upstream_dns}"
              ]
            }
        }
        if [resolved_ip] {
          geoip {
            source => "resolved_ip"
          }
        }
        mutate {
          rename => { "host" => "syslog_host" }
        }
        # Target is to parse the the first and second significant part of the domain
        grok {
          patterns_dir => ["${./patterns}"]
          match => { "domain" => [ "%{PUBLIC_SUFFIX:dns_suffix}$" ] }
        }
        if [client] {
          mutate { copy => { "client" => "clientip" } }
          dns {
            reverse => [ "client"]
            action => "replace"
            hostsfile => [ "/etc/hosts" ]
            hit_cache_ttl => 1600
            failed_cache_ttl => 60
          }
        }
    }
  '' + ''
    if ( [program] == "proftpd") {
      kv {
        field_split => "  "
      }
    }
    '';
    outputConfig = 
    ''
      #stdout {
      #  codec => rubydebug
      #}
      elasticsearch { }
    '';
  };
}
