{ config, pkgs, lib, ... }:
let
  kodi-host = "192.168.8.11";
  unstable = import <nixpkgs-unstable> {};
  confdir = "/var/lib/homeassistant-docker";
in {
  imports = [
    ./ota.nix
    ./comic-updater.nix
    # ./puppy-proxy.nix

    ./zigbee2mqtt

    # hass config
    ## complex configs
    # ./multi/daily-standup.nix
    #./multi/aramark.nix
    #./multi/matrix.nix
    #./multi/frosch.nix
    #./multi/mittagessen.nix
    #./multi/10h_timers.nix

    #./switch/tasmota_switch.nix
    #./switch/rfbridge.nix

    #./light/statuslight.nix
    #./light/buzzer.nix

    #./script/multi_blink.nix

    #./binary_sensor/buttons.nix
    #./binary_sensor/motion.nix

    ## ./sensor/pollen.nix requires dwd_pollen
    #./sensor/espeasy.nix
    #./sensor/airquality.nix
    #./sensor/outside.nix
    #./sensor/tasmota_firmware.nix

    #./camera/verkehrskamera.nix
    #./camera/comic.nix
    #./camera/stuttgart.nix
    #./automation/bureau-shutdown.nix
    #./automation/nachtlicht.nix
    #./automation/schlechteluft.nix
    #./automation/philosophische-tuer.nix
    #./automation/hass-restart.nix
    #./device_tracker/openwrt.nix
    #./person/team.nix
  ];

  networking.firewall.allowedTCPPorts = [ 8123 ];
  state = [ "/var/lib/hass/known_devices.yaml" ];
  virtualisation.oci-containers.containers.hass = {
    image = "homeassistant/home-assistant:latest";
    #user = "${toString config.users.users.kiosk.uid}:${toString config.users.groups.kiosk.gid}";
    #user = "${toString config.users.users.kiosk.uid}:root";
    environment = {
      TZ = "Europe/Berlin";
      PUID = toString config.users.users.kiosk.uid;
      PGID = toString config.users.groups.kiosk.gid;
      UMASK = "007";
    };
    extraOptions = ["--net=host" ];
    volumes = [
      "${confdir}:/config"
      #"${confdir}/docker-run:/etc/services.d/home-assistant/run:"
    ];
  };
  systemd.tmpfiles.rules = [
    #"f ${confdir}/docker-run 0770 kiosk kiosk - -"
    "d ${confdir} 0770 kiosk kiosk - -"
  ];
  #services.home-assistant = {
  #  enable = true;
  #  package = (unstable.home-assistant.overrideAttrs (old: {
  #    doInstallCheck = false;
  #  })).override {
  #    extraPackages = p: [ 
  #      # TODO: put somewhere else
  #      (p.callPackage <stockholm/makefu/2configs/home/ham/deps/dwdwfsapi.nix> {})
  #      # (p.callPackage <stockholm/makefu/2configs/home/ham/deps/pykodi.nix> {})
  #      p.APScheduler ];
  #  };
  #  autoExtraComponents = true;
  #  config = {
  #    config = {};
  #    discovery = {};
  #    homeassistant = {
  #      name = "Bureautomation";
  #      time_zone = "Europe/Berlin";
  #      latitude = "48.8265";
  #      longitude = "9.0676";
  #      elevation = 303;
  #      auth_providers = [
  #        { type = "homeassistant";}
  #        { type = "legacy_api_password";
  #          api_password = "sistemas";
  #        }
  #        { type = "trusted_networks";
  #          trusted_networks = [
  #            "127.0.0.1/32"
  #            "192.168.8.0/24"
  #            "::1/128"
  #            "fd00::/8"
  #          ];
  #          # allow_bypass_login = true;
  #        }
  #      ];
  #    };
  #    # https://www.home-assistant.io/components/influxdb/
  #    influxdb = {
  #      database = "hass";
  #      tags = {
  #        instance = "wbob";
  #        source = "hass";
  #      };
  #    };
  #    mqtt = {
  #      discovery = true;
  #      discovery_prefix = "homeassistant";
  #      broker = "localhost";
  #      port = 1883;
  #      client_id = "home-assistant";
  #      keepalive = 60;
  #      protocol = 3.1;
  #      birth_message = {
  #        topic = "/bam/hass/tele/LWT";
  #        payload = "Online";
  #        qos = 1;
  #        retain = true;
  #      };
  #      will_message = {
  #        topic = "/bam/hass/tele/LWT";
  #        payload = "Offline";
  #        qos = 1;
  #        retain = true;
  #      };
  #    };
  #    notify = [
  #      {
  #        platform = "kodi";
  #        name = "wbob-kodi";
  #        host = kodi-host;
  #      }
  #      #{
  #      #  platform = "telegram";
  #      #  name = "telegrambot";
  #      #  chat_id = builtins.elemAt
  #      #    (builtins.fromJSON (builtins.readFile
  #      #      <secrets/hass/telegram-bot.json>)).allowed_chat_ids 0;
  #      #}
  #    ];
  #    media_player = [
  #      { platform = "kodi";
  #        host = kodi-host;
  #      }
  #      { platform = "mpd";
  #        host = "127.0.0.1";
  #      }
  #    ];

  #    # sensor = [{ platform = "version"; }]; # pyhaversion



  #    frontend = { };
  #    http = {
  #      # TODO: https://github.com/home-assistant/home-assistant/issues/16149
  #      # base_url = "http://192.168.8.11:8123";
  #    };
  #    conversation = {};
  #    history = {};
  #    logbook = {};
  #    tts = [
  #      { platform = "google_translate";
  #        language = "de";
  #        time_memory = 57600;
  #        service_name =  "google_say";
  #      }
  #      { platform = "voicerss";
  #        api_key = builtins.readFile <secrets/hass/voicerss.apikey>;
  #        language = "de-de";
  #      }
  #      #{ platform = "picotts";
  #      #  language = "de-DE";
  #      #}
  #    ];
  #    recorder = {};
  #    sun = {};
  #    #telegram_bot = [
  #    #  (builtins.fromJSON
  #    #    (builtins.readFile <secrets/hass/telegram-bot.json>))
  #    #];
  #    # only for automation
  #    # feedreader.urls = [ "http://www.heise.de/security/rss/news-atom.xml" ];
  #    # we don't use imports because the expressions do not merge in
  #    # home-assistant
  #  };
  #};
}
