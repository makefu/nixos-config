let
  espeasy_dht22 = name: [
  { platform = "mqtt";
    name = "${name} DHT22 Temperature";
    device_class = "temperature";
    state_topic = "/bam/${name}/dht22/Temperature";
    availability_topic = "/bam/${name}/tele/LWT";
    payload_available = "Online";
    payload_not_available = "Offline";
  }
  { platform = "mqtt";
    device_class = "humidity";
    name = "${name} DHT22 Humidity";
    state_topic = "/bam/${name}/dht22/Humidity";
    availability_topic = "/bam/${name}/tele/LWT";
    payload_available = "Online";
    payload_not_available = "Offline";
  }];
  espeasy_ds18 = name:
  { platform = "mqtt";
    name = "${name} DS18 Temperature";
    state_topic = "/bam/${name}/ds18/Temperature";
    availability_topic = "/bam/${name}/tele/LWT";
    payload_available = "Online";
    payload_not_available = "Offline";
  };
in
(espeasy_dht22 "easy1") ++
(espeasy_dht22 "easy2") ++ [
  (espeasy_ds18 "easy3" )
]
