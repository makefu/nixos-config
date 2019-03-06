[
  { alias = "Turn on Fernseher on movement";
    trigger = {
      platform = "state";
      entity_id = "binary_sensor.motion";
      to = "on";
    };
    action = {
      service = "homeassistant.turn_on";
      entity_id =  [
        "switch.fernseher"
        "switch.feuer"
      ];
    };
  }
  { alias = "Turn off Fernseher 10 minutes after last movement";
    trigger = [
    { # trigger when movement was detected at the time
      platform = "state";
      entity_id = "binary_sensor.motion";
      to = "off";
      for.minutes = 10;
    }
    { # trigger at 20:00 no matter what
      # to avoid 'everybody left before 18:00:00'
      platform = "time";
      at = "18:00:00";
    }
  ];
    action = {
      service = "homeassistant.turn_off";
      entity_id =  [
        "switch.fernseher"
        "switch.feuer"
        "light.status_felix"
      ];
    };
    condition =
    { condition = "and";
      conditions = [
        {
          condition = "time";
          before = "06:30:00"; #only turn off between 6:30 and 18:00
          after  = "18:00:00";
          # weekday = [ "mon" "tue" "wed" "thu" "fri" ];
        }
        {
          condition = "state";
          entity_id = "binary_sensor.motion";
          state = "off";
        }
      ];
    };
  }
]
