{ pkgs, lib, ...}:

let
  genTopic_zigbee = name: tags: {
      servers = [ "tcp://localhost:1883" ];
      username = "stats";
      password = lib.removeSuffix "\n" (builtins.readFile <secrets/mqtt/stats>);
      qos = 0;
      connection_timeout = "30s";
      topics = [ "/ham/zigbee/${name}" ];
      inherit tags;
      persistent_session = false;
      name_override = "zigbee ${tags.room} ${name}";
      data_format = "json";
      json_string_fields = [ "linkquality" "temperature" "humidity" "pressure" "battery" "contact" ];
      # json_name_key = <filed which defines the name>

    };
  genTopic_plain = name: topic: tags: {
      servers = [ "tcp://localhost:1883" ];
      username = "stats";
      password = lib.removeSuffix "\n" (builtins.readFile <secrets/mqtt/stats>);
      qos = 0;
      connection_timeout = "30s";
      topics = [ topic ];
      inherit tags;
      persistent_session = false;
      name_override = tags.sensor;
      data_type = "float";
      data_format = "value";
      # json_query = tags.sensor; #TODO?
    };
    flycounter = name:
            (genTopic_plain name ''/ham/flycounter/${name}''
                      { inherit name;
                       "sensor" = name;
                       "type" = "gauge";
                       "scope" = "ham";
                      } );
    esensor = room: name: sensor:
            (genTopic_plain sensor ''/ham/${room}/${name}/sensor/${sensor}/state''
                      { inherit room sensor name;
                       "scope" = "ham";
                      } );
    zsensor = room: name:
            (genTopic_zigbee name
                      { inherit room name;
                       "scope" = "ham";
                      } );
    zigbee_temphum = room: name: [
      (zsensor room name)
    ];
    esphome_temphum = room: name: [
      (esensor room name ''${room}_${name}_temperature'')
      (esensor room name ''${room}_${name}_humidity'')
      (esensor room name ''${room}_${name}_pressure'')
    ];
in {
  services.telegraf.extraConfig.inputs.mqtt_consumer =
       (zigbee_temphum "Wohnzimmer" "temp1")
    ++ (zigbee_temphum "Badezimmer" "temp2")
    ++ (zigbee_temphum "Kinderzimmer" "temp3")
    ++ (esphome_temphum "arbeitszimmer" "box")
    ++ (esphome_temphum "schlafzimmer" "plug")
    ++ (esphome_temphum "wohnzimmer" "plug")
    ++ (esphome_temphum "terrasse" "plug")
    ++ [ (flycounter "misa_fliegen") (flycounter "felix_fliegen") ]
    ;
}
