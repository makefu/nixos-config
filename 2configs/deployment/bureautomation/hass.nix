{ pkgs, lib, ... }:
let
  tasmota_plug = name: topic: {
          platform = "mqtt";
          inherit name;
          state_topic = "/bam/${topic}/stat/POWER";
          command_topic = "/bam/${topic}/cmnd/POWER";
          availability_topic = "/bam/${topic}/tele/LWT";
          qos = 1;
          payload_on= "ON";
          payload_off= "OFF";
          payload_available= "Online";
          payload_not_available= "Offline";
          retain= false;
        };
  espeasy_dht22 = name: [
    {
          platform = "mqtt";
          device_class = "temperature";
          state_topic = "/bam/${name}/dht22/Temperature";
          availability_topic = "/bam/${name}/status/LWT";
          payload_available = "Connected";
          payload_not_available = "Connection Lost";
    }
    {
          platform = "mqtt";
          device_class = "humidity";
          state_topic = "/bam/${name}/dht22/Temperature";
          unit_of_measurement =  "C";
          availability_topic = "/bam/${name}/status/LWT";
          payload_available = "Connected";
          payload_not_available = "Connection Lost";
    }];
  espeasy_ds18 = name: [
    {
          platform = "mqtt";
          device_class = "temperature";
          state_topic = "/bam/${name}/ds18/Temperature";
          availability_topic = "/bam/${name}/status/LWT";
          payload_available = "Connected";
          payload_not_available = "Connection Lost";
    }
  ];
in {

  nixpkgs.config.permittedInsecurePackages = [
    "homeassistant-0.65.5"
  ];

  services.home-assistant = {
    enable = true;
    config = {
      homeassistant = {
        name = "Bureautomation";
        time_zone = "Europe/Berlin";
      };

      mqtt = {
        broker = "localhost";
        port = 1883;
        client_id = "home-assistant";
        keepalive = 60;
        protocol = 3.1;
        birth_message = {
          topic = "/bam/hass/tele/LWT";
          payload = "Online";
          qos = 1;
          retain = true;
        };
        will_message = {
          topic = "/bam/hass/tele/LWT";
          payload = "Offline";
          qos = 1;
          retain = true;
        };
      };
      switch = [
        (tasmota_plug "Bauarbeiterlampe" "plug")
        (tasmota_plug "Blitzdings" "plug2")
        (tasmota_plug "Fernseher" "plug3")
        (tasmota_plug "Pluggy" "plug4")
      ];
      binary_sensor = [
        { # esp_easy 
          platform = "mqtt";
          device_class = "motion";
          state_topic = "/bam/easy2/movement/Switch";
          payload_on = "1";
          payload_off = "0";
          availability_topic = "/bam/easy2/status/LWT";
          payload_available = "Connected";
          payload_not_available = "Connection Lost";
        }
      ];
      sensor =
          (espeasy_dht22 "easy2") ++
        [ (espeasy_ds18 "easy3" )
          { platform = "luftdaten";
            name = "Ditzingen";
            sensorid = "5341";
            monitored_conditions = [ "P1" "P2" ];
          }
          { platform = "influxdb";
            queries = [
              { name = "mean value of feinstaub P1";
                where = '' "node" = 'esp8266-1355142' '';
                measurement = "feinstaub";
                database = "telegraf";
                field = "P1";
              }
              { name = "mean value of feinstaub P2";
                where = '' "node" = 'esp8266-1355142' '';
                measurement = "feinstaub";
                database = "telegraf";
                field = "P2";
              }
            ];
          }
        ];
      frontend = { };
      http = { };
      feedreader.urls = [ "http://www.heise.de/security/rss/news-atom.xml" ];
    };
  };
}
