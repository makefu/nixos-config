{ pkgs, lib, config, ... }:

# Ideas:
## wake-on-lan server
##
let
  hlib = (import ./lib);
  prefix = hlib.prefix;
  tasmota = hlib.tasmota;
  firetv_stick = "192.168.1.24";
  hassdir = "/var/lib/hass";
  zigbee = import ./multi/zigbee2mqtt.nix;
  flurlicht = import ./multi/flurlicht.nix;
  kurzzeitwecker = import ./multi/kurzzeitwecker.nix;
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
      timer = zigbee.timer // kurzzeitwecker.timer; # dict
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
          host = firetv_stick;
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
          host = firetv_stick;
        }
        { platform = "androidtv";
          name = "FireTV Stick";
          device_class = "firetv";
          # adb_server_ip = firetv_stick;
          host = firetv_stick;
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
      luftdaten = {
        show_on_map = true;
        sensor_id = 679;
        sensors.monitored_conditions = [ "P1" "P2" ];
      };
      binary_sensor =
         zigbee.binary_sensor
      ++ flurlicht.binary_sensor;
      sensor = [
        { platform = "speedtest";
          monitored_conditions = [ "ping" "download" "upload" ];
        }
        # https://www.home-assistant.io/cookbook/automation_for_rainy_days/
      ]
      ++ ((import ./sensor/outside.nix) {inherit lib;})
      ++ zigbee.sensor ;
      frontend = { };
      light = flurlicht.light;
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
      switch =
         zigbee.switch;
      automation =
         flurlicht.automation
      ++ kurzzeitwecker.automation
      ++ zigbee.automation;
      script = kurzzeitwecker.script; # dict
    };
    enable = true;
    configDir = hassdir;
  };

}
