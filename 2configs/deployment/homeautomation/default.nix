{ pkgs, config, ... }:
let
  firetv = "192.168.1.238";
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
      };
      media_player = [
        { platform = "kodi";
          host = firetv;
        }
        { platform = "firetv";
          # assumes python-firetv running
        }
      ];
      sensor = [
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
      ];
      frontend = { };
      http = { };
    };
    enable = true;
    #configDir = "/var/lib/hass";
  };
}
