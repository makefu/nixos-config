{ pkgs, lib, config, ... }:
# Ideas:
## wake-on-lan server
##
let
  prefix = (import ./lib).prefix;
  hassdir = "/var/lib/hass";


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
    ./multi/heizung.nix
    # ./multi/fliegen-couter.nix

    ./device_tracker/openwrt.nix
    ./device_tracker/tile.nix

    ./sensor/outside.nix
    ./sensor/pollen.nix
    ./sensor/dwd.nix

    ./calendar/nextcloud.nix

    ./media/firetv.nix
    ./media/sonos.nix
    ./media/schlafzimmer_music_remote.nix
    ./media/remote_sound_wohnzimmer.nix
    ./media/remote_sound_arbeitszimmer.nix
    ./media/arbeitszimmer_matrix.nix

    ./automation/check-in.nix
    ./automation/fenster_auf.nix
    ./automation/firetv_restart.nix
    ./automation/light_buttons.nix
    ./automation/wohnzimmer_rf_fernbedienung.nix
    # ./automation/ladestecker_timer.nix
    ./automation/flurlicht.nix
    # ./automation/giesskanne.nix 
    # ./automation/pflanzen_giessen_erinnerung.nix
    ./automation/find_phone.nix
    ./automation/urlaub.nix
    ./automation/moodlight.nix
    ./automation/shutdown_button.nix
    ./automation/project_tracker.nix
    ./automation/daily_speedtext.nix


    ./light/arbeitszimmer.nix
    ./light/schlafzimmer.nix
    ./light/wohnzimmer.nix

    ./tts/google.nix
  ];

  services.home-assistant = {
    extraComponents = [ "mobile_app" ];
    extraPackages = python3Packages: with python3Packages; [ pytz ];

    config = {
      default_config = {}; # for sonos aiodiscover

      influxdb = {
        api_version = 1;
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
      binary_sensor  = [
        { platform = "workday";
          name = "Arbeitstag";
          country = "DE";
          province = "BW";
        }
        { platform = "workday";
          name = "Arbeitstag Morgen";
          country = "DE";
          province = "BW";
          days_offset = 1;
        }
        { platform = "workday";
          name = "Arbeitstag Gestern";
          country = "DE";
          province = "BW";
          days_offset = 1;
        }
      ];
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
      luftdaten = {
        # show_on_map = true;
        sensor_id = 72935;
        # sensors.monitored_conditions = [ "P1" "P2" ];
      };
      #binary_sensor =
      #   flurlicht.binary_sensor;

      sensor = [
        # https://www.home-assistant.io/cookbook/automation_for_rainy_days/
      ];
      frontend = { };
      speedtestdotnet = { };
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
      media_source = {};
    };
    enable = true;
    configDir = hassdir;
  };

  krebs.secret.files."hass-secrets" = {
    source-path = toString <secrets> + "/hass/secrets.yaml";
    path = "/var/lib/hass/secrets.yaml";
    owner.name = "hass";
  };
  state = [ "/var/lib/hass/known_devices.yaml" ];
}
