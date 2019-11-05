{ lib }:
let
  random_daily_text = ''{{ [
    "Es ist so weit, es ist Standup Zeit!",
    "Zehn Uhr Fünfunddreissig ist genau die richtige Zeit für ein Standup!",
    "Hat jeder seine Hausaufgaben gemacht? Bitte einmal aufstehen und den Zettel nach rechts geben",
    "Aufstehen zum Appell, es wird die Anwesenheit kontrolliert!",
    "Hallo Kinder, wisst ihr welche Zeit es ist??? ... Genau! ... Standup Zeit!",
    "Morgens, halb elf in Deutschland - das Standupchen" ] | random }}'';

in {
  script =
  { "random_daily" = {
      alias = "Random Daily Introduction";

      sequence = [
        { service = "media_player.play_media";
          data = {
            entity_id = "media_player.mpd";
            media_content_type = "playlist";
            media_content_id = "ansage";
          };
        }
        { delay.seconds = 5; }
        { service = "tts.google_say";
          entity_id =  "media_player.mpd";
          data_template = {
            message = random_daily_text;
            language = "de";
          };
        }
      ];
    };
  };
  automation = [
    {
      alias = "Daily Standup";
      trigger = {
        platform = "time";
        at = "10:35:00";
      };
      action =
        [
          { service = "homeassistant.turn_on";
          entity_id =  [
            "script.blitz_10s"
            "script.random_daily"
          ];
        }
      ];

    }
  ];
}
