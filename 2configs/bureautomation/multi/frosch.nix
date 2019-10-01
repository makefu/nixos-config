{ lib }:
let

   random_pommes = '' {{ [
     "Nur ein Pommes Tag ist ein guter Tag",
     "Schaut wie schön sie fliegen, die Pommes Seifenblasen",
     "zwo ... eins ... Pommes Zeit",
     "I cannot believe it is not Pommes",
     "Naja, wenn es sonst schon nichts anderes gibt, kann man jetzt auch pommes nehmen",
     "Wenn Aramark was kann, dann ist es frittieren",
     "Einmal das Hauptgericht mit Pommes, ohne Hauptgericht",
     "Rieche ich da etwa Pommes? JA!",
     "Pommes ist auch nur Gemüse,also keine Reue und schlag zu!",
     "Mit nur fünf Portionen Pommes kann man schon satt werden.",
     "Heute für Sie, 15 Pommes von hand abgezählt",
     "Der Weltmarktpreis von Pommes ist durch verschiedene Weltkrisen leider so hoch, dass Aramark den Verkaufspreis verdoppeln musste.",
     "Vorfreude, schönste Freude, Freude bei Aramark. Pommes in die Schale rein, alle Kunden werden glücklich sein.",
     "In 15 Minuten ist es wieder so weit, es ist Pommes Zeit!"] | random }}'';
in {
  sensor = [
    { platform = "mqtt";
      name = "frosch brightness";
      device_class = "illuminance";
      state_topic = "/bam/frosch/sensor/brightness/state";
      availability_topic = "/bam/frosch/status";
      payload_available = "online";
      payload_not_available = "offline";
    }
  ];
  binary_sensor = [
    { platform = "mqtt";
      name = "frosch auge";
      state_topic = "/bam/frosch/binary_sensor/froschauge/state";
      availability_topic = "/bam/frosch/status";
      payload_available = "online";
      payload_not_available = "offline";
    }
  ];
  switch = [
    { platform = "mqtt";
      name = "frosch blasen";
      state_topic = "/bam/frosch/switch/blasen/state";
      command_topic = "/bam/frosch/switch/blasen/command";
      availability_topic = "/bam/frosch/status";
      payload_available = "online";
      payload_not_available = "offline";
    }
  ];
  light = [];
  automation = [
    { alias = "Pommeszeit";
      trigger = {
        platform = "time";
        at = "12:15:00";
      };
      condition = {
        condition = "state";
        entity_id = "binary_sensor.pommes"; # from multi/aramark.nix
        state =  "on";
      };
      action = [
      { service = "homeassistant.turn_on";
          entity_id =  [
            "script.pommes_announce"
            "script.seifenblasen_30s" # from script/multi_blink.nix
          ];
        }
      ];
    }
  ];
  script = {
    pommes_announce = {
      alias = "Random Pommes announce";
      sequence = [
        {
          service = "media_player.play_media";
          data = {
            entity_id = "media_player.mpd";
            media_content_type = "playlist";
            media_content_id = "ansage";
          };
        }
        { delay.seconds = 5; }
        {
          service = "tts.google_say";
          entity_id =  "media_player.mpd";
          data_template = {
            message = random_pommes;
            language = "de";
          };
        }
      ];
    };
  };
}
