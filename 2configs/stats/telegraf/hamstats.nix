{ pkgs, ...}:

let
  genTopic = name: topic: tags: {
      servers = [ "tcp://localhost:1883" ];
      username = "stats";
      password = builtins.readFile <secrets/mqtt/stats>;
      qos = 0;
      connection_timeout = "30s";
      topics = [ topic ];
      tags = tags;
      persistent_session = false;
      name_override = name;
      data_format = "json";
      # json_query = tags.sensor; #TODO?
    };
  hamStat = host:
            sensor:
            (genTopic sensor
                      "/ham/${host}/${sensor}/tele/SENSOR"
                      {"host" = host;
                       "scope" = "ham";
                       "sensor" = sensor;
                      } );
  bme = host: [(hamStat host "BME280")];
in {
  services.telegraf.extraConfig.inputs.mqtt_consumer = (bme "schlafzimmer");
}
