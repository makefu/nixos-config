{ pkgs, lib, ... }:
let
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
      switch = (import ./switch/tasmota_switch.nix);
      light =  (import ./light/statuslight.nix) ++
               (import ./light/buzzer.nix);
      timer = {
        felix_10h = {
          name = "Felix 10h Timer";
          duration = "10:00:00";
        };
        felix_8_30h = {
          name = "Felix 8_30h Timer";
          duration = "08:30:00";
        };
        felix_7h = {
          name = "Felix 7h Timer";
          duration = "07:00:00";
        };
      };
      notify = [
        {
          platform = "kodi";
          name = "wbob";
          host = "192.168.8.11";
        }
      ];
      script = (import ./script/multi_blink.nix) {inherit lib;};
      binary_sensor =
        (import ./binary_sensor/buttons.nix) ++
        (import ./binary_sensor/motion.nix);

      sensor =
        (import ./sensor/espeasy.nix) ++
        ((import ./sensor/outside.nix) {inherit lib;}) ++
        (import ./sensor/influxdb.nix);

      camera =
        (import ./camera/verkehrskamera.nix);

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
              # "group.camera"
            ];
          };
        automation = [
          "timer.felix_10h"
          "script.blitz_10s"
          "script.buzz_red_led_fast"
          "camera.Baumarkt"
        ];
        switches = [
          "switch.bauarbeiterlampe"
          "switch.blitzdings"
          "switch.fernseher"
          "switch.feuer"
          "switch.nachtlicht"
          "light.status_felix"
          "light.status_daniel"
          "light.buslicht"
          "light.redbutton_buzzer"
        ];

        camera = [ ];
        sensors = [
          "binary_sensor.motion"
          "binary_sensor.redbutton"
          "sensor.easy2_dht22_humidity"
          "sensor.easy2_dht22_temperature"
        ];
        outside = [
          # "sensor.ditzingen_pm10"
          # "sensor.ditzingen_pm25"
          "sensor.dark_sky_temperature"
          "sensor.dark_sky_humidity"
          # "sensor.dark_sky_pressure"
          "sensor.dark_sky_hourly_summary"
          "camera.Autobahn_Heilbronn"
          "camera.Autobahn_Singen"
        ];
      };
      # only for automation
      # feedreader.urls = [ "http://www.heise.de/security/rss/news-atom.xml" ];
      # we don't use imports because the expressions do not merge in
      # home-assistant
      automation = (import ./automation/bureau-shutdown.nix) ++
                   (import ./automation/nachtlicht.nix) ++
                   (import ./automation/10h_timer.nix);

    };
  };
}
