{ pkgs, lib, ... }:
let
  tasmota_plug = name: topic:
  { platform = "mqtt";
    inherit name;
    state_topic = "/bam/${topic}/stat/POWER1";
    command_topic = "/bam/${topic}/cmnd/POWER1";
    availability_topic = "/bam/${topic}/tele/LWT";
    payload_on= "ON";
    payload_off= "OFF";
    payload_available= "Online";
    payload_not_available= "Offline";
  };
  tasmota_stecki = name: topic:
    ( tasmota_plug name topic) //
    { state_topic = "/bam/${topic}/stat/POWER";
      command_topic = "/bam/${topic}/cmnd/POWER";
  };
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
in {
  networking.firewall.allowedTCPPorts = [ 8123 ];

  services.home-assistant = {
    enable = true;
    config = {
      homeassistant = {
        name = "Bureautomation";
        time_zone = "Europe/Berlin";
        latitude = "48.8265";
        longitude = "9.0676";
        elevation = 303;
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
        (tasmota_stecki "Fernseher" "fernseher")
        (tasmota_plug "Pluggy" "plug4")
      ];
      binary_sensor = [
        { platform = "mqtt";
          device_class = "motion";
          name = "Motion";
          state_topic = "/bam/easy2/movement/Switch";
          payload_on = "1";
          payload_off = "0";
          availability_topic = "/bam/easy2/tele/LWT";
          payload_available = "Online";
          payload_not_available = "Offline";
        }
      ];
      sensor =
          (espeasy_dht22 "easy1") ++
          (espeasy_dht22 "easy2") ++
        [ (espeasy_ds18 "easy3" )
          { platform = "luftdaten";
            name = "Ditzingen";
            sensorid = "5341";
            monitored_conditions = [ "P1" "P2" ];
          }

          { platform = "darksky";
            api_key = lib.removeSuffix "\n"
              (builtins.readFile <secrets/hass/darksky.apikey>);
            language = "de";
            monitored_conditions = [ "summary" "icon"
            "nearest_storm_distance" "precip_probability"
            "precip_intensity"
            "temperature" # "temperature_high" "temperature_low"
            "apparent_temperature"
            "hourly_summary" # next 24 hours text
            "minutely_summary"
            "humidity"
            "pressure"
            "uv_index" ];
            units =  "si" ;
            update_interval = {
                  days = 0;
                  hours = 0;
                  minutes = 30;
                  seconds = 0;
            };
          }
          #{ platform = "influxdb";
          #  queries = [
          #    { name = "mean value of feinstaub P1";
          #      where = '' "node" = 'esp8266-1355142' '';
          #      measurement = "feinstaub";
          #      database = "telegraf";
          #      field = "P1";
          #    }
          #    { name = "mean value of feinstaub P2";
          #      where = '' "node" = 'esp8266-1355142' '';
          #      measurement = "feinstaub";
          #      database = "telegraf";
          #      field = "P2";
          #    }
          #  ];
          #}
        ];
        camera = [
          { name = "Baumarkt";
            platform = "generic";
            still_image_url = http://t4915209254324-p80-c0-h6jv2afnujcoftrcstsafb45kdrqv4buy.webdirect.mdex.de/oneshotimage ;# baumarkt
          }
          { name = "Autobahn Heilbronn";
            platform = "generic";
            still_image_url = https://api.svz-bw.de/v2/verkehrskameras/kameras/K10 ;
          }
          { name = "Autobahn Singen";
            platform = "generic";
            still_image_url = https://api.svz-bw.de/v2/verkehrskameras/kameras/K11 ;
          }
        ];
      frontend = { };
      http = { };
      conversation = {};
      history = {};
      logbook = {};
      tts = [ { platform = "google";} ];
      recorder = {};
      group =
      { default_view =
        { view = "yes";
          entities = [
              "group.sensors"
              "group.outside"
              "group.switches"
              "group.automation"
              "group.camera"
            ];
          };
        automation = [
          "automation.turn_off_fernseher_10_minutes_after_last_movement"
        ];
        switches = [
          "switch.bauarbeiterlampe"
          "switch.blitzdings"
          "switch.fernseher"
          "switch.pluggy"
        ];
        camera = [
          "camera.Baumarkt"
          "camera.Autobahn_Heilbronn"
          "camera.Autobahn_Singen"
        ];
        sensors = [
          "binary_sensor.motion"
          "sensor.easy2_dht22_humidity"
          "sensor.easy2_dht22_temperature"
        ];
        outside = [
          "sensor.ditzingen_pm10"
          "sensor.ditzingen_pm25"
          "sensor.dark_sky_temperature"
          "sensor.dark_sky_humidity"
          "sensor.dark_sky_pressure"
          "sensor.dark_sky_hourly_summary"
          "sensor.dark_sky_minutely_summary"
        ];
      };
      # only for automation
      # feedreader.urls = [ "http://www.heise.de/security/rss/news-atom.xml" ];
      automation = [
        { alias = "Turn on Fernseher on movement";
          trigger = {
            platform = "state";
            entity_id = "binary_sensor.motion";
            to = "on";
          };
          action = {
            service= "homeassistant.turn_on";
            entity_id= "switch.fernseher";
          };
        }
        { alias = "Turn off Fernseher 10 minutes after last movement";
          trigger = {
            platform = "state";
            entity_id = "binary_sensor.motion";
            to = "off";
            for.minutes = 10;
          };
          action = {
            service= "homeassistant.turn_off";
            entity_id= "switch.fernseher";
          };
          condition = [{
            condition = "time";
            before = "06:30:00"; #only turn off between 6:30 and 18:00
            after  = "18:00:00";
            weekday = [ "mon" "tue" "wed" "thu" "fri" ];
          }];
        }
      ];
    };
  };
}
