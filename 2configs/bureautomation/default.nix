{ config, pkgs, lib, ... }:
let
  kodi-host = "192.168.8.11";
  ten_hours = import ./combination/10h_timers.nix { inherit lib; }; # provides: timer automation script
  mittagessen = import ./combination/mittagessen.nix { inherit lib; }; # provides: automation script
  matrix = import ./combination/matrix.nix { inherit lib; }; # provides: matrix automation
in {
  imports = [
    ./ota.nix
  ];
  networking.firewall.allowedTCPPorts = [ 8123 ];
  state = [ "/var/lib/hass/known_devices.yaml" ];
  services.home-assistant = let
      dwd_pollen = pkgs.fetchFromGitHub {
        owner = "marcschumacher";
        repo = "dwd_pollen";
        rev = "0.1";
        sha256 = "1af2mx99gv2hk1ad53g21fwkdfdbymqcdl3jvzd1yg7dgxlkhbj1";
      };
    in {
    enable = true;
    package = (pkgs.home-assistant.overrideAttrs (old: {
      # TODO: find correct python package
      postInstall = ''
        cp -r ${dwd_pollen} $out/lib/python3.7/site-packages/homeassistant/components/dwd_pollen
      '';
    })).override {
      extraPackages = ps: with ps; [
        pkgs.pico2wave
        python-forecastio jsonrpc-async jsonrpc-websocket mpd2
        (callPackage ./deps/gtts-token.nix { })
        (callPackage ./deps/pyhaversion.nix { })
      ];
    };
    autoExtraComponents = true;
    config = {
      homeassistant = {
        name = "Bureautomation";
        time_zone = "Europe/Berlin";
        latitude = "48.8265";
        longitude = "9.0676";
        elevation = 303;
        auth_providers = [
          { type = "homeassistant";}
          { type = "legacy_api_password";}
          { type = "trusted_networks";
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
      matrix = matrix.matrix;
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
      switch = (import ./switch/tasmota_switch.nix) ++
              (import ./switch/rfbridge.nix);
      light =  (import ./light/statuslight.nix) ++
              (import ./light/buzzer.nix);
      timer = ten_hours.timer;
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
      ] ++ matrix.notify;
      media_player = [
        { platform = "kodi";
          host = kodi-host;
        }
        { platform = "mpd";
          host = "127.0.0.1";
        }
      ];
      script = lib.fold lib.recursiveUpdate {} [
        ((import ./script/multi_blink.nix) {inherit lib;})
        ten_hours.script
        mittagessen.script
      ];
      binary_sensor =
        (import ./binary_sensor/buttons.nix) ++
        (import ./binary_sensor/motion.nix);

      sensor =
        [{ platform = "version"; }] ++
        (import ./sensor/pollen.nix) ++
        (import ./sensor/espeasy.nix) ++
        (import ./sensor/airquality.nix) ++
        ((import ./sensor/outside.nix) {inherit lib;}) ++
        (import ./sensor/influxdb.nix) ++
        (import ./sensor/tasmota_firmware.nix);

      camera =
        (import ./camera/verkehrskamera.nix);

      # not yet released
      #person =
      #  (import ./person/team.nix );

      frontend = { };
      http = {
        # TODO: https://github.com/home-assistant/home-assistant/issues/16149
        base_url = "http://192.168.8.11:8123";
        api_password = "sistemas";
        trusted_networks = [
          "127.0.0.1/32"
          "192.168.8.0/24"
          "::1/128"
          "fd00::/8"
        ];
      };
      conversation = {};
      history = {};
      logbook = {};
      tts = [
        { platform = "google";
          language = "de";
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
            ];
          };
        automation = [];

        switches = [
          "switch.bauarbeiterlampe"
          "switch.blitzdings"
          "switch.fernseher"
          "switch.feuer"
          "light.status_felix"
          "light.status_daniel"
          "light.buslicht"
        ];
        team = [
          "device_tracker.thorsten_phone"
          "device_tracker.felix_phone"
          "device_tracker.ecki_tablet"
          "device_tracker.daniel_phone"
          "device_tracker.carsten_phone"
          "device_tracker.thierry_phone"
          "device_tracker.frank_phone"
          "device_tracker.anthony_phone"
        #  "person.thorsten"
        #  "person.felix"
        #  "person.ecki"
        #  "person.daniel"
        ];
        camera = [
          "camera.Baumarkt"
          "camera.Autobahn_Heilbronn"
          "camera.Autobahn_Singen"
        ];
        nachtlicht = [
          "switch.nachtlicht_a"
          "switch.nachtlicht_b"
          "switch.nachtlicht_c"
          "switch.nachtlicht_d"
        ];
        sensors = [
          "media_player.kodi"
          "script.blitz_10s"
          "script.buzz_red_led_fast"
          "timer.felix_10h"
          "timer.frank_10h"
          "sensor.easy2_dht22_humidity"
          "sensor.easy2_dht22_temperature"
          "sensor.air_quality"
          # "binary_sensor.redbutton"
        ];
        outside = [
          # "sensor.ditzingen_pm10"
          # "sensor.ditzingen_pm25"
          "sensor.dark_sky_icon"
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
      automation = (import ./automation/bureau-shutdown.nix) ++
                  (import ./automation/nachtlicht.nix) ++
                  (import ./automation/schlechteluft.nix) ++
                  (import ./automation/hass-restart.nix) ++
                  ten_hours.automation ++
                  matrix.automation ++
                  mittagessen.automation;
      device_tracker = (import ./device_tracker/openwrt.nix );
    };
  };
}
