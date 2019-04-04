[
        {
          alias = "Turn off Nachtlicht on sunrise";
          trigger =
          {
            platform = "sun";
            event = "sunrise";
          };
          action =
          {
            service = "homeassistant.turn_off";
            entity_id =  [ "group.nachtlicht" ];
          };
        }

        {
          alias = "Turn on Nachtlicht on motion and dusk";
          trigger =
          {
            platform = "state";
            entity_id = "binary_sensor.motion";
            to = "on";
          };
          condition = # 'when dark'
          {
            condition = "or";
            conditions = [
              { condition = "sun";
                after = "sunset";
                after_offset = "-00:45:00"; # on dusk
              }
              { condition = "sun";
                before = "sunrise";
              }
            ];
          };
          action =
          {
            service = "homeassistant.turn_on";
            entity_id =  [ "group.nachtlicht" ];
          };
        }
]
