{ pkgs, config, ... }:

# Ideas:
## wake-on-lan server
## 
let
  firetv = "192.168.1.238";
  tasmota_plug = name: topic:
  { platform = "mqtt";
    inherit name;
    state_topic = "/ham/${topic}/stat/POWER1";
    command_topic = "/ham/${topic}/cmnd/POWER1";
    availability_topic = "/ham/${topic}/tele/LWT";
    payload_on= "ON";
    payload_off= "OFF";
    payload_available= "Online";
    payload_not_available= "Offline";
  };
  tasmota_bme = name: topic:
  [ { platform = "mqtt";
      name = "${name} Temperatur";
      state_topic = "/ham/${topic}/tele/SENSOR";
      value_template = "{{ value_json.BME280.Temperature }}";
      unit_of_measurement = "°C";
    }
    { platform = "mqtt";
      name = "${name} Luftfeuchtigkeit";
      state_topic = "/ham/${topic}/tele/SENSOR";
      value_template = "{{ value_json.BME280.Humidity }}";
      unit_of_measurement = "%";
    }
    { platform = "mqtt";
      name = "${name} Luftdruck";
      state_topic = "/ham/${topic}/tele/SENSOR";
      value_template = "{{ value_json.BME280.Pressure }}";
      unit_of_measurement = "hPa";
    }
  ];
in {
  imports = [
    ./mqtt.nix
  ];
  systemd.services.firetv = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "nobody";
      ExecStart = "${pkgs.python-firetv}/bin/firetv-server -d ${firetv}:5555";
    };
  };
  nixpkgs.config.permittedInsecurePackages = [
    "homeassistant-0.65.5"
  ];
  services.home-assistant = {
    config = {
      homeassistant = {
        name = "Home"; time_zone = "Europe/Berlin";
        latitude = "48.7687";
        longitude = "9.2478";
        elevation = 247;
      };
      discovery = {};
      conversation = {};
      history = {};
      logbook = {};
      tts = [
        { platform = "google";}
      ];
      sun.elevation = 247;
      recorder = {};
      media_player = [
        { platform = "kodi";
          host = firetv;
        }
        { platform = "firetv";
          # assumes python-firetv running
        }
      ];
      mqtt = {
        broker = "localhost";
        port = 1883;
        client_id = "home-assistant";
        username = "hass";
        password = builtins.readFile <secrets/mqtt/hass>;
        keepalive = 60;
        protocol = 3.1;
        birth_message = {
          topic = "/ham/hass/tele/LWT";
          payload = "Online";
          qos = 1;
          retain = true;
        };
        will_message = {
          topic = "/ham/hass/tele/LWT";
          payload = "Offline";
          qos = 1;
          retain = true;
        };
      };
      sensor = [
        { platform = "speedtest";
          monitored_conditions = [ "ping" "download" "upload" ];
        }
        { platform = "luftdaten";
          name = "Ditzingen";
          sensorid = "663";
          monitored_conditions = [ "P1" "P2" ];
        }
        # https://www.home-assistant.io/cookbook/automation_for_rainy_days/
        { platform = "darksky";
          api_key = "c73619e6ea79e553a585be06aacf3679";
          language = "de";
          monitored_conditions = [ "summary" "icon"
          "nearest_storm_distance" "precip_probability"
          "precip_intensity"
          "temperature" # "temperature_high" "temperature_low"
          "hourly_summary"
          "uv_index" ];
          units =  "si" ;
          update_interval = {
                days = 0;
                hours = 0;
                minutes = 10;
                seconds = 0;
          };
        }
      ] ++ (tasmota_bme "Schlafzimmer" "schlafzimmer");
      frontend = { };
      #group = [
      #  { default_view = { view = "yes"; entities = [
      #    "sensor.luftdaten"
      #  ]}
      #];
      http = { };
      switch = [
        (tasmota_plug "Lichterkette Schlafzimmer" "schlafzimmer")
      ];
    };
    enable = true;
    #configDir = "/var/lib/hass";
  };
}
