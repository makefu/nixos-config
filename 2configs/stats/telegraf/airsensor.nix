{ pkgs, ...}:
let
  genTopic = name: topic: tags: {
      servers = [ "tcp://localhost:1883" ];
      qos = 0;
      connection_timeout = "30s";
      topics = [ topic ];
      tags = tags;
      persistent_session = false;
      name_override = name;
      data_format = "value";
      data_type = "float";
    };
  bamStat = stat:   # Temperature or Humidity
            host:   # easy{1-4}
            sensor: # dht11, dht22, ds18
            (genTopic stat
                      "/bam/${host}/${sensor}/${stat}"
                      {"host" = host;
                       "scope" = "bam";
                       "sensor" = sensor;
                      } );
  dht22 = host: [(bamStat "Temperature" host "dht22")
                 (bamStat "Humidity" host "dht22")];
  dht11 = host: [(bamStat "Temperature" host "dht11")
                 (bamStat "Humidity" host "dht11")];
  ds18 = host:  [(bamStat "Temperature" host "ds18")];
in {
  services.udev.extraRules = ''
    SUBSYSTEMS=="usb", ATTRS{product}=="iAQ Stick", GROUP="input"
  '';
  users.users.telegraf.extraGroups = [ "input" ];
  services.telegraf.extraConfig.inputs.exec =  [
    {
      commands = [ "${pkgs.airsensor-py}/bin/airsensor-py"];
      timeout = "10s";
      data_format = "value";
      data_type = "integer";
      name_override = "airquality";
      interval = "10s";
      tags.unit="VOC";
    }
  ];
  services.telegraf.extraConfig.inputs.mqtt_consumer =
       (dht22 "easy1")
    ++ (dht22 "easy2")
    ++ (dht11 "easy3")
    ++ (ds18  "easy3");
}
