{ pkgs, lib, config, ... }:

# Ideas:
## wake-on-lan server
## 
let
  tasmota_rgb = name: topic:
# LED WS2812b
#      effect_state_topic: "stat/led/Scheme"
#      effect_command_topic: "cmnd/led/Scheme"
#      effect_value_template: "{{ value_json.Scheme }}"
  { platform = "mqtt";
    inherit name;
    retain = false;
    qos = 1;
    optimistic = false;
    # state
    # TODO: currently broken, will not use the custom state topic
    #state_topic = "/ham/${topic}/stat/POWER";
    state_topic = "/ham/${topic}/stat/POWER";
    command_topic = "/ham/${topic}/cmnd/POWER";
    availability_topic = "/ham/${topic}/tele/LWT";
    payload_on= "ON";
    payload_off= "OFF";
    payload_available= "Online";
    payload_not_available= "Offline";
    # brightness
    brightness_state_topic = "/ham/${topic}/stat/Dimmer";
    brightness_command_topic = "/ham/${topic}/cmnd/Dimmer";
    brightness_value_template = "{{ value_json.Dimmer }}";
    brightness_scale = 100;
    # color
    rgb_state_topic = "/ham/${topic}/stat/Color";
    rgb_command_topic = "/ham/${topic}/cmnd/Color2";
    rgb_command_mode = "hex";
    rgb_command_template = "{{ '%02x%02x%02x' | format(red, green, blue)}}";
    # effects
    effect_state_topic = "/ham/${topic}/stat/Scheme";
    effect_command_topic = "/ham/${topic}/cmnd/Scheme";
    effect_value_template = "{{ value_json.Scheme }}";
    effect_list = [ 0 1 2 3 4 5 6 7 8 9 10 11 12 ];
};
    # switchmode 1 - also toggle power
    # switchtopic flurlicht
    tasmota_motion = name: topic:
    { platform = "mqtt";
      device_class = "motion";
      inherit name;
      # TODO: currently broken, will not use the custom state topic
      state_topic = "/ham/${topic}/stat/POWER";
      payload_on = "ON";
      payload_off = "OFF";
      availability_topic = "/ham/${topic}/tele/LWT";
      payload_available = "Online";
      payload_not_available = "Offline";
    };

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
  tasmota_am2301 = name: topic:
  [ { platform = "mqtt";
      name = "${name} Temperatur";
      state_topic = "/ham/${topic}/tele/SENSOR";
      value_template = "{{ value_json.AM2301.Temperature }}";
      unit_of_measurement = "°C";
    }
    { platform = "mqtt";
      name = "${name} Luftfeuchtigkeit";
      state_topic = "/ham/${topic}/tele/SENSOR";
      value_template = "{{ value_json.AM2301.Humidity }}";
      unit_of_measurement = "%";
    }
  ];
in {
  imports = [
    ./mqtt.nix
  ];
  #systemd.services.firetv = {
  #  wantedBy = [ "multi-user.target" ];
  #  serviceConfig = {
  #    User = "nobody";
  #    ExecStart = "${pkgs.python-firetv}/bin/firetv-server -d ${firetv}:5555";
  #  };
  #};
  services.home-assistant = {
    config = {
      homeassistant = {
        name = "Home"; time_zone = "Europe/Berlin";
        latitude = "48.7687";
        longitude = "9.2478";
        elevation = 247;
      };
      #discovery = {};
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
        #{ platform = "firetv";
        #  # assumes python-firetv running
        #}
      ];
      mqtt = {
        broker = "localhost";
        port = 1883;
        client_id = "home-assistant";
        username = "hass";
        password = lib.removeSuffix "\n" (builtins.readFile <secrets/mqtt/hass>);
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
      binary_sensor = [
        (tasmota_motion "Flur Bewegung" "flurlicht")
      ];
      sensor = [
        # broken
        #{ platform = "speedtest";
        #  monitored_conditions = [ "ping" "download" "upload" ];
        #}
        { platform = "luftdaten";
          name = "Wangen";
          sensorid = "663";
          monitored_conditions = [ "P1" "P2" ];
        }
        # https://www.home-assistant.io/cookbook/automation_for_rainy_days/
        { platform = "darksky";
          api_key = lib.removeSuffix "\n"
            (builtins.readFile <secrets/hass/darksky.apikey>);
          language = "de";
          monitored_conditions = [ "summary" "icon"
          "nearest_storm_distance" "precip_probability"
          "precip_intensity"
          "temperature"
          "apparent_temperature"
          "hourly_summary"
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
      ]
      ++ (tasmota_bme "Schlafzimmer" "schlafzimmer")
      ++ (tasmota_am2301 "Arbeitszimmer" "arbeitszimmer");
      frontend = { };
      group =
        { default_view =
          { view = "yes";
            entities = [
              "group.flur"
              "group.schlafzimmer"
              "group.draussen"
              "group.wohnzimmer"
              "group.arbeitszimmer"
            ];
          };
          flur = [
            "light.flurlicht"
            "binary_sensor.flur_bewegung"
          ];
          wohnzimmer = [
            "media_player.kodi"
          ];
          draussen = [
            "sensor.dark_sky_temperature"
            "sensor.dark_sky_hourly_summary"
            "sensor.wangen_pm10"
            "sensor.wangen_pm25"
          ];
          schlafzimmer = [
            "sensor.schlafzimmer_temperatur"
            "sensor.schlafzimmer_luftdruck"
            "sensor.schlafzimmer_luftfeuchtigkeit"
            "switch.lichterkette_schlafzimmer"
          ];
          arbeitszimmer = [
            "switch.strom_staubsauger"
            "sensor.arbeitszimmer_temperatur"
            "sensor.arbeitszimmer_luftfeuchtigkeit"
          ];
        };
      http = { };
      switch = [
        (tasmota_plug "Lichterkette Schlafzimmer" "schlafzimmer")
        (tasmota_plug "Strom Staubsauger" "arbeitszimmer")
      ];
      light = [ (tasmota_rgb "Flurlicht" "flurlicht" ) ];
      automation = [
        { alias = "Staubsauger Strom aus nach 6h";
          trigger = {
            platform = "state";
            entity_id = "switch.strom_staubsauger";
            to = "on";
            for.hours = 6;
          };
          action = {
            service= "homeassistant.turn_off";
            entity_id= "switch.strom_staubsauger";
          };
        }
      ];
    };
    enable = true;
    #configDir = "/var/lib/hass";
  };
}
