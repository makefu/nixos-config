let
  long_threshold = 30;
in
{
  services.home-assistant.config.automation =
  [
    {
      alias = "Bad Air Alarm 60 seconds";
      trigger =
      { platform = "numeric_state";
        entity_id = "sensor.air_quality";
        above = 1523;
        for.seconds = 60;
      };
      condition = {
        condition = "and";
        conditions = [
          { condition = "state";
            entity_id = "group.team";
            state = "home";
          }
          { condition = "time";
            after   = "06:00:00";
            before  = "20:00:00";
          }
        ];
      };

      action = [
        { service = "homeassistant.turn_on";
          entity_id = [
            "script.schlechteluft"
          ];
        }
      ];
    }
    {
      alias = "Bad Air Alarm ${toString long_threshold} Minutes";
      trigger =
      { platform = "numeric_state";
        entity_id = "sensor.air_quality";
        above = 1523;
        for.minutes = long_threshold;
      };
      condition = {
        condition = "and";
        conditions = [
          { condition = "state";
            entity_id = "group.team";
            state = "home";
          }
          { condition = "time";
            after   = "06:00:00";
            before  = "20:00:00";
          }
        ];
      };

      action = [
        { service = "homeassistant.turn_on";
          entity_id = [
            "script.schlechteluft"
          ];
        }
        { service = "tts.google_say";
          entity_id =  "media_player.mpd";
          data_template = {
            message = "BEEP BEEP - Die luft ist schon ${toString long_threshold} Minuten schlecht! Student Nummer {{ range(1,500) | random }}, öffne ein Fenster.";
            language = "de";
          };
        }
      ];
    }
  ];
}
