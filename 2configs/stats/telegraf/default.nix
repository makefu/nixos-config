{...}:
let
  url = "http://localhost:8086";
  mqtt_server = "localhost:1883";
in {
  services.telegraf = {
    enable = true;
    extraConfig = {
      agent.debug = false;
      outputs = {
        influxdb = [{
          urls = [ url ];
          database = "telegraf";
        }];
        #file = [{ # debugging
        #  files = [ "stdout" ];
        #  data_format = "influx";
        #}];

        mqtt = [{
          servers = [ mqtt_server ];
          topic_prefix = "/telegraf";
          data_format = "json";
          qos = 0;
          batch = false;
        }];
      };
    };
  };
}
