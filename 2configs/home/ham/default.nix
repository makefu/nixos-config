{ pkgs, lib, config, ... }:
# Ideas:
## wake-on-lan server
##
let
  prefix = (import ./lib).prefix;
  hassdir = "/var/lib/hass";
  unstable = import <nixpkgs-unstable> {};


in {
  imports = [
    ./nginx.nix
    ./mqtt.nix
    ./signal-rest

    # hass config
    ./zigbee2mqtt.nix
    # ./multi/flurlicht.nix
    ./multi/kurzzeitwecker.nix
    ./multi/the_playlist.nix
    # ./multi/fliegen-couter.nix

    ./device_tracker/openwrt.nix
    ./device_tracker/tile.nix

    ./sensor/outside.nix

    ./calendar/nextcloud.nix

    ./media/firetv.nix
    ./media/sonos.nix
    ./media/remote_sound_wohnzimmer.nix
    ./media/remote_sound_arbeitszimmer.nix

    ./automation/check-in.nix
    ./automation/fenster_auf.nix
    ./automation/firetv_restart.nix
    ./automation/light_buttons.nix
    ./automation/wohnzimmer_rf_fernbedienung.nix
    # ./automation/ladestecker_timer.nix
    ./automation/flurlicht.nix
    ./automation/giesskanne.nix
    ./automation/pflanzen_giessen_erinnerung.nix
    ./automation/urlaub.nix
    ./automation/moodlight.nix
    ./automation/shutdown_button.nix

    ./light/arbeitszimmer.nix
    ./light/schlafzimmer.nix
    ./light/wohnzimmer.nix

    ./tts/google.nix
  ];

  services.home-assistant = {
    package = (pkgs.home-assistant.overrideAttrs (old: {
      doInstallCheck = false;
    })).override {
      extraPackages = p: [
        (p.callPackage ./deps/dwdwfsapi.nix {})
        (p.callPackage ./signal-rest/pkg.nix {})
        (p.callPackage ./deps/pykodi.nix {})
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
      homeassistant = {
        name = "Home"; time_zone = "Europe/Berlin";
        latitude = "48.7687";
        longitude = "9.2478";
        elevation = 247;
        auth_providers = [
          { type = "trusted_networks";
            trusted_networks = [ "192.168.1.0/24" ];
            allow_bypass_login = true;
          }
          { type = "homeassistant"; }
        ];
      };
      discovery = {};
      conversation = {};
      history = {};
      logbook = {};
      logger = {
        default = "info";
      };
      rest_command = {};
      api = {};
      esphome = {}; # fails
      camera = [];
      #telegram_bot = [
      #  # secrets file: {
      #  #  "platform": "broadcast",
      #  #  "api_key": "", # talk to Botfather /newbot
      #  #  "allowed_chat_ids": [ ID ] # curl -X GET #  https://api.telegram.org/bot<YOUR_API_TOKEN>/getUpdates
      #  # }
      #  (builtins.fromJSON
      #    (builtins.readFile <secrets/hass/telegram-bot.json>))
      #];
      notify = [
        #{
        #  platform = "telegram";
        #  name = "telegrambot";
        #  chat_id = builtins.elemAt
        #    (builtins.fromJSON (builtins.readFile
        #      <secrets/hass/telegram-bot.json>)).allowed_chat_ids 0;
        #}
          ];
      sun.elevation = 247;
      recorder = {};
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
      #luftdaten = {
      #  show_on_map = true;
      #  sensor_id = 10529;
      #  sensors.monitored_conditions = [ "P1" "P2" ];
      #};
      #binary_sensor =
      #   flurlicht.binary_sensor;

      sensor = [
        { platform = "speedtestdotnet";
          scan_interval.hours = 6;
          monitored_conditions = [ "ping" "download" "upload" ];
        }
        # https://www.home-assistant.io/cookbook/automation_for_rainy_days/
      ];
      frontend = { };
      http = {
        use_x_forwarded_for = true;
        #server_host = "127.0.0.1";
        server_host = "0.0.0.0";
        trusted_proxies = [ "127.0.0.1" ];
        #trusted_proxies = [ "192.168.1.0/24" ];
      };
      switch = [];
      automation = [];
      script = { };
    };
    enable = true;
    configDir = hassdir;
  };

  state = [ "/var/lib/hass/known_devices.yaml" ];
}
