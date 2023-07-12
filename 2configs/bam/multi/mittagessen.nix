{ lib, ... }:
let
  # TODO: remove redundant code (from multi_blink) via lib
  flash_entity = { entity, delay ? 500, count ? 4, alias ?  "${entity}_blink_${toString count}_${toString delay}" }:
  {
    inherit alias;
    sequence = lib.flatten (builtins.genList (i: [
      { service = "homeassistant.turn_on";
        data.entity_id = entity;
      }
      { delay.milliseconds = delay; }
      { service = "homeassistant.turn_off";
        data.entity_id = entity;
      }
      { delay.milliseconds = delay; }
    ]
     ) count);
   };
   # TODO: use influxdb and check if pommes
   random_mittagessen = '' {{ [
     "Es ist 12 uhr 30. Der Aramark Gourmettempel hat, wie jeden Tag, wieder die feinsten Köstlichkeiten für euch Vorbereitet",
     "Heute bei Aramark: Rezepte aus Ländern, von denen Ihr noch nie gehört habt, Deutsch zubereitet",
     "Heute bei Aramark im Angebot: Scheiss mit Reis oder Reste von Freitag",
     "MHHHH es ist wieder mal so weit, lecker Bayerisch Kraut mit asiatischen Nudeln",
     "Es ist 12 Uhr 30 und Heute gibt es nur Pommes, wenn der Pommesfrosch Blasen gespuckt hat.",
     "Heute gibt es Pommes leider nicht einzeln zu verkaufen, da die Schälchen alle sind",
     "Heute gibt es Pommes, verarscht! Natürlich gibt es nur salzlosen Reis, oder salzlose Nudeln.",
     "Heute auf dem Speiseplan: Sushi vom Vortag",
     "Aramark Kantinenessen: Der Hunger treibt es rein, der Geiz hält es drin.",
     "Das Essen in der Snackeria sieht heute wie die bessere Alternative aus",
     "Heute ist wohl wieder ein Beilagen-Tag",
     "Lunch time! Good luck, you will need it!",
     "Heute vielleicht lieber doch nur einen Salat?",
     "Im Büro ist es eh gerade viel zu warm, also ab zur Kantine",
     "Im Büro ist es eh gerade viel zu kalt, also ab zur Kantine",
     "Heute scheint die Auswahl wieder sehr schwierig zu sein. Vielleicht doch lieber ein Brötchen mit Fleischkäse vom Bäcker beim Baumarkt?",
     "Wer hat hier schon wieder ein Meeting auf 12 Uhr gelegt? Skandal!",
     "Jetzt nur noch kurz die Mail fertig schreiben und schon kann es los gehen.",
     "Es ist 13 Uhr und die Mittagspause ist bald vorbei .... Kleiner Scherz, es ist erst 12:30, aber Ihr hättet auch nicht wirklich etwas verpasst.",
     "Hallo, es ist nun 12 Uhr 30! Dies entspricht der Essenszeit aller Büroinsassen. Bitte begebt euch zur Aramark Essensausgabe um euren menschlichen Bedürfnissen nachzukommen."] | random }}'';
in
{
  services.home-assistant.config = {
    automation = [
      { alias = "Mittagessen";
        trigger = {
          platform = "time";
          at = "12:30:00";
        };
        action = [
        { service = "homeassistant.turn_on";
            entity_id =  [
              "script.mittagessen_announce"
              "script.blitz_10s"
              "script.mittagessenlicht"
            ];
          }
        ];
      }
    ];
    script = {
      mittagessenlicht = (flash_entity {
        entity = "switch.bauarbeiterlampe";
        alias = "Bauarbeiterlampe Mittagessenlicht";
        delay = 1000;
        count = 5;
      });
      mittagessen_announce = {
        alias = "Random Mittagessen announce";
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
              message = random_mittagessen;
              language = "de";
            };
          }
        ];
      };
    };
  };
}
