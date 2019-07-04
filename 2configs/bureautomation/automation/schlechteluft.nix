let
secs = 60;
in [
  {
    alias = "Bad Air Alarm";
    trigger =
    { platform = "numeric_state";
      entity_id = "sensor.air_quality";
      above = 1523;
      for.seconds = secs;
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
      { service = "notify.matrix_notify";
        data_template.message = "Bad Air Alarm! VOC above threshold for ${toString secs} seconds ({{states.sensor.air_quality.state_with_unit}})";
      }
    ];
  }
]
