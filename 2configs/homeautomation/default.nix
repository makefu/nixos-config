{ pkgs, lib, config, ... }:

# Ideas:
## wake-on-lan server
##
let
  hlib = (import ./lib);
  prefix = hlib.prefix;
  tasmota = hlib.tasmota;
  firetv = "192.168.1.183";
  kodi-host = firetv;
  hassdir = "/var/lib/hass";
  zigbee = import ./multi/zigbee2mqtt.nix;
#   switch
#   automation
#   binary_sensor
#   sensor
#   input_select
#   timer
in {
  imports = [
    ./mqtt.nix
  ];

  services.home-assistant = {
    config = {
      input_select = zigbee.input_select; # dict
      timer = zigbee.timer; # dict
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
        { platform = "google_translate";
          language = "de";
          time_memory = 57600;
          service_name =  "google_say";
        }
      ];

      telegram_bot = [
        # secrets file: {
        #  "platform": "broadcast",
        #  "api_key": "", # talk to Botfather /newbot
        #  "allowed_chat_ids": [ ID ] # curl -X GET #  https://api.telegram.org/bot<YOUR_API_TOKEN>/getUpdates
        #}
        (builtins.fromJSON
          (builtins.readFile <secrets/hass/telegram-bot.json>))
      ];
      notify = [
        {
          platform = "kodi";
          name = "wohnzimmer";
          host = kodi-host;
        }
        {
          platform = "telegram";
          name = "telegrambot";
          chat_id = builtins.elemAt
            (builtins.fromJSON (builtins.readFile
              <secrets/hass/telegram-bot.json>)).allowed_chat_ids 0;
            }
          ];
      sun.elevation = 247;
      recorder = {};
      media_player = [
        { platform = "kodi";
          host = firetv;
        }
        { platform = "firetv";
          name = "FireTV Stick";
          host = firetv;
          adbkey = <secrets/hass/adbkey>;
        }
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
          topic = "${prefix}/hass/tele/LWT";
          payload = "Online";
          qos = 1;
          retain = true;
        };
        will_message = {
          topic = "${prefix}/hass/tele/LWT";
          payload = "Offline";
          qos = 1;
          retain = true;
        };
      };
      binary_sensor = [
        (tasmota.motion { name = "Flur Bewegung"; host = "flurlicht";})
      ] ++ zigbee.binary_sensor;
      sensor = [
        # broken
        #{ platform = "speedtest";
        #  monitored_conditions = [ "ping" "download" "upload" ];
        #}
        # https://www.home-assistant.io/cookbook/automation_for_rainy_days/
      ]
      ++ ((import ./sensor/outside.nix) {inherit lib;})
      ++ zigbee.sensor
      ++ (tasmota.bme { name = "Schlafzimmer"; host =  "schlafzimmer";})
      ++ (tasmota.am2301 { name= "Arbeitszimmer" ; host = "arbeitszimmer"; });
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
            "automation.dunkel_bei_sonnenuntergang"
            "automation.hell_bei_sonnenaufgang"
          ];
          wohnzimmer = [
            "media_player.kodi"
            "media_player.firetv_stick"
          ];
          draussen = [
            "sensor.dark_sky_temperature"
            "sensor.dark_sky_hourly_summary"
            "sensor.dark_sky_humidity"
            "sensor.dark_sky_pressure"
            "sensor.muehlhausen_pm10"
            "sensor.muehlhausen_pm25"
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
        (tasmota.plug { name = "Lichterkette Schlafzimmer"; host = "schlafzimmer";})
        (tasmota.plug { name = "Strom Staubsauger"; host = "arbeitszimmer"; } )
      ] ++ zigbee.switch;
      light = [ (tasmota.rgb { name = "Flurlicht"; host = "flurlicht";} ) ];
      automation = [
        { alias = "Dunkel bei Sonnenuntergang";
          trigger = {
            platform = "sun";
            event = "sunset";
            # offset: "-00:45:00"
          };
          action = [
            {
              service= "light.turn_on";
              data = {
                entity_id= "light.flurlicht";
                # rgb_color = [ 0,0,0 ]; <-- TODO default color
                brightness_pct = 15;
              };
            }
            {
              service= "light.turn_off";
              entity_id= "light.flurlicht";
            }
          ];
        }
        { alias = "Hell bei Sonnenaufgang";
          trigger = {
            platform = "sun";
            event = "sunrise";
            # offset: "-00:00:00"
          };
          action = [
            {
              service= "light.turn_on";
              data = {
                entity_id= "light.flurlicht";
                brightness_pct = 85;
              };
            }
            {
              service= "light.turn_off";
              entity_id= "light.flurlicht";
            }
          ];
        }
        #{ alias = "Staubsauger Strom aus nach 6h";
        #  trigger = {
        #    platform = "state";
        #    entity_id = "switch.strom_staubsauger";
        #    to = "on";
        #    for.hours = 6;
        #  };
        #  action = {
        #    service= "homeassistant.turn_off";
        #    entity_id= "switch.strom_staubsauger";
        #  };
        #}
      ] ++ zigbee.automation;
    };
    enable = true;
    configDir = hassdir;
  };

}
