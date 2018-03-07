{ pkgs, lib, ... }:
let
  firetv = "192.168.1.238";
in {
  imports = [
    <nixpkgs-unstable/nixos/modules/services/misc/home-assistant.nix>
  ];
  systemd.services.firetv = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "nobody";
      ExecStart = "${pkgs.python-firetv}/bin/firetv-server -d ${firetv}:5555";
    };
  };
  nixpkgs.config.packageOverrides = oldpkgs: {
    home-assistant = (import <nixpkgs-unstable> {}).home-assistant;
  };
  ids.uids.hass = 286;
  ids.gids.hass = 286;
  services.home-assistant = {
  #panel_iframe:
  #configurator:
  #  title: Configurator
  #  icon: mdi:wrench
  #  url: http://hassio.local:3218
  # sensor:
  # - platform: random
    enable = true;
    config = {
      homeassistant = {
        name = "Bureautomation";
        time_zone = "Europe/Berlin";
      };
      panel_iframe = {
        euer_blog = {
          title = "Euer Blog";
          icon =  "mdi:wrench";
          url = "https://euer.krebsco.de";
        };
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
        {
          platform = "luftdaten";
          name = "Shack 1";
          sensorid = "50";
          monitored_conditions = [ "P1" "P2" ];
        }
        {
          platform = "luftdaten";
          name = "Shack 2";
          sensorid = "658";
          monitored_conditions = [ "P1" "P2" ];
        }
        {
          platform = "luftdaten";
          name = "Ditzingen";
          sensorid = "5341";
          monitored_conditions = [ "P1" "P2" ];
        }
        { platform = "random"; }
      ];
      frontend = { };
      http = { };
      feedreader.urls = [ "https://nixos.org/blogs.xml" ];
    };
  };
}
