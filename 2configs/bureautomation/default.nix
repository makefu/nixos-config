{ config, pkgs, lib, ... }:
let
  kodi-host = "192.168.8.11";
in {
  imports = [
    ./ota.nix
    ./comic-updater.nix
    ./puppy-proxy.nix

    # hass config
    ## complex configs
    ./multi/daily-standup.nix
    ./multi/aramark.nix
    ./multi/matrix.nix
    ./multi/frosch.nix
    ./multi/mittagessen.nix
    ./multi/10h_timers.nix

    ./switch/tasmota_switch.nix
    ./switch/rfbridge.nix

    ./light/statuslight.nix
    ./light/buzzer.nix

    ./script/multi_blink.nix

    ./binary_sensor/buttons.nix
    ./binary_sensor/motion.nix

    # ./sensor/pollen.nix requires dwd_pollen
    ./sensor/espeasy.nix
    ./sensor/airquality.nix
    ./sensor/outside.nix
    ./sensor/tasmota_firmware.nix

    ./camera/verkehrskamera.nix
    ./camera/comic.nix
    ./camera/stuttgart.nix
    ./automation/bureau-shutdown.nix
    ./automation/nachtlicht.nix
    ./automation/schlechteluft.nix
    ./automation/hass-restart.nix
    ./device_tracker/openwrt.nix
    ./person/team.nix
  ];
  networking.firewall.allowedTCPPorts = [ 8123 ];
  state = [ "/var/lib/hass/known_devices.yaml" ];

  services.home-assistant = {
    enable = true;
    autoExtraComponents = true;
    config = {
      config = {};
      discovery = {};
      homeassistant = {
        name = "Bureautomation";
        time_zone = "Europe/Berlin";
        latitude = "48.8265";
        longitude = "9.0676";
        elevation = 303;
        auth_providers = [
          { type = "homeassistant";}
          { type = "legacy_api_password";
            api_password = "sistemas";
          }
          { type = "trusted_networks";
            trusted_networks = [
              "127.0.0.1/32"
              "192.168.8.0/24"
              "::1/128"
              "fd00::/8"
            ];
            # allow_bypass_login = true;
          }
        ];
      };
      # https://www.home-assistant.io/components/influxdb/
      influxdb = {
        database = "hass";
        tags = {
          instance = "wbob";
          source = "hass";
        };
      };
      mqtt = {
        discovery = true;
        discovery_prefix = "homeassistant";
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
      notify = [
        {
          platform = "kodi";
          name = "wbob-kodi";
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
      media_player = [
        { platform = "kodi";
          host = kodi-host;
        }
        { platform = "mpd";
          host = "127.0.0.1";
        }
      ];

      sensor = [{ platform = "version"; }]; # pyhaversion



      frontend = { };
      http = {
        # TODO: https://github.com/home-assistant/home-assistant/issues/16149
        base_url = "http://192.168.8.11:8123";
      };
      conversation = {};
      history = {};
      logbook = {};
      tts = [
        { platform = "google_translate";
          language = "de";
          time_memory = 57600;
          service_name =  "google_say";
        }
        { platform = "voicerss";
          api_key = builtins.readFile <secrets/hass/voicerss.apikey>;
          language = "de-de";
        }
        { platform = "picotts";
          language = "de-DE";
        }
      ];
      recorder = {};
      sun = {};
      telegram_bot = [
        (builtins.fromJSON
          (builtins.readFile <secrets/hass/telegram-bot.json>))
      ];
      group =
      { default_view =
        { view = "yes";
          entities = [
              "group.sensors"
              "group.camera"
              "group.outside"
              "group.team"
              "group.nachtlicht"
              "group.switches"
              "group.aramark"
            ];
          };
        automation = [];

        switches = [
          "switch.bauarbeiterlampe"
          "switch.blitzdings"
          "switch.fernseher"
          "switch.feuer"
          "switch.frosch_blasen"
          "light.status_felix"
          # "light.status_daniel"
          # "light.buslicht"
        ];
        team = [
          "person.thorsten"
          #"device_tracker.thorsten_phone"
          "person.felix"
          "person.ecki"
          "person.daniel"
          # "person.carsten"
          "person.thierry"
          "person.frank"
          "person.emeka"
          "person.tancrede"
          #"device_tracker.felix_phone"
          #"device_tracker.ecki_tablet"
          #"device_tracker.daniel_phone"
          #"device_tracker.carsten_phone"
          #"device_tracker.thierry_phone"
          #"device_tracker.frank_phone"
          #"device_tracker.emeka_phone"
        #  "person.thorsten"
        #  "person.felix"
        #  "person.ecki"
        #  "person.daniel"
        ];
        camera = [
          "camera.Baumarkt"
          "camera.Autobahn_Heilbronn"
          "camera.Autobahn_Singen"
          "camera.puppies"
          "camera.poorly_drawn_lines"
          "camera.xkcd"
        ];
        nachtlicht = [
          "switch.nachtlicht_a"
          "switch.nachtlicht_b"
          "switch.nachtlicht_c"
          "switch.nachtlicht_d"
        ];
        Aramark = [
          "binary_sensor.pommes"
          "sensor.menu_1"
          "sensor.menu_1_text"
          "sensor.menu_1_preis"
          "sensor.menu_2"
          "sensor.menu_2_text"
          "sensor.menu_2_preis"
          "sensor.aktion"
          "sensor.aktion_text"
          "sensor.aktion_preis"
          "sensor.mercato"
          "sensor.mercato_text"
          "sensor.mercato_preis"
        ];
        sensors = [
          "media_player.kodi"
          "timer.felix_10h"
          "timer.frank_10h"
          "sensor.easy2_dht22_humidity"
          "sensor.easy2_dht22_temperature"
          "sensor.air_quality"
          # "binary_sensor.aramark_pommes"
          # "binary_sensor.redbutton"
        ];
        outside = [
          # "sensor.ditzingen_pm10"
          # "sensor.ditzingen_pm25"
          "sensor.dark_sky_temperature"
          "sensor.dark_sky_humidity"
          "sensor.dark_sky_uv_index"
          # "sensor.dark_sky_pressure"
          "sensor.dark_sky_hourly_summary"
        ];
      };
      # only for automation
      # feedreader.urls = [ "http://www.heise.de/security/rss/news-atom.xml" ];
      # we don't use imports because the expressions do not merge in
      # home-assistant
    };
  };
}
