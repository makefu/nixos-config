{ pkgs, lib, config, ... }:

# Ideas:
## wake-on-lan server
##
let
  upkgs = (import <nixpkgs-unstable> {}).pkgs;
  hlib = (import ./lib);
  prefix = hlib.prefix;
  tasmota = hlib.tasmota;
  firetv_stick = "192.168.1.24";
  hassdir = "/var/lib/hass";
  zigbee = import ./multi/zigbee2mqtt.nix;
  #flurlicht = import ./multi/flurlicht.nix;
  kurzzeitwecker = import ./multi/kurzzeitwecker.nix;
  firetv_restart = import ./multi/firetv_restart.nix;
  the_playlist = import ./multi/the_playlist.nix;
  fliegen-counter = import ./multi/fliegen-couter.nix;
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
    package = (upkgs.home-assistant.overrideAttrs (old: {
      doCheck = false;
      checkPhase = ":";
      installCheckPhase = ":";
    })).override {
      extraPackages = ps: with ps; [
        python-forecastio jsonrpc-async jsonrpc-websocket mpd2 pkgs.picotts androidtv
      ];
    };
    config = {
      influxdb = {
        database = "ham";
        host = "localhost";
        tags = {
          instance = "omo";
          source = "hass";
        };
      };

      config = {};
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
      counter = fliegen-counter.counter;
      logger = {
        default = "info";
      };
      rest_command = {}
      // the_playlist.rest_command;
      tts = [
        { platform = "google_translate";
          language = "de";
          time_memory = 57600;
          service_name =  "google_say";
        }
      ];
      api = {};
      esphome = {};
      camera = [];
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
      device_tracker = (import ./device_tracker/openwrt.nix);
      media_player = [
        { platform = "FireTV Stick kodi";
          host = firetv_stick;
        }
        { platform = "androidtv";
          name = "FireTV Stick";
          device_class = "firetv";
          # adb_server_ip = firetv_stick;
          host = firetv_stick;
          port = 5555;
        }
      ];
      mqtt = {
        broker = "localhost";
        discovery = true; #enable esphome discovery
        discovery_prefix = "homeassistant";
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
        sensor_id = 10529;
        sensors.monitored_conditions = [ "P1" "P2" ];
      };
      #binary_sensor =
      #   flurlicht.binary_sensor;
      sensor = [
        { platform = "speedtest";
          monitored_conditions = [ "ping" "download" "upload" ];
        }
        # https://www.home-assistant.io/cookbook/automation_for_rainy_days/
      ]
      ++ ((import ./sensor/outside.nix) {inherit lib;})
      ++ the_playlist.sensor
      ++ zigbee.sensor ;
      frontend = { };
      calendar = [ (import ./calendar/nextcloud.nix) ];
      # light = flurlicht.light;
      http = { };
      switch = [];
      automation = []
        ++ (import ./automation/firetv_restart.nix)
        ++ kurzzeitwecker.automation
        #++ flurlicht.automation
        ++ the_playlist.automation
        ++ fliegen-counter.automation
        ++ zigbee.automation;
        script =
        { }
        // kurzzeitwecker.script; # dict
    };
    enable = true;
    configDir = hassdir;
  };

  state = [ "/var/lib/hass/known_devices.yaml" ];
}
