[
  { alias = "Turn on Fernseher on group home";
    trigger = {
      condition = "state";
      entity_id = "group.team";
      from = "not_home";
      to = "home";
    };
    action = {
      service = "homeassistant.turn_on";
      entity_id =  [
        "switch.fernseher"
        "switch.feuer"
      ];
    };
  }
  { alias = "Turn off Fernseher after last in group left";
    trigger = [
    { # trigger when movement was detected at the time
      condition = "state";
      entity_id = "group.team";
      from = "home";
      to = "not_home";
    }
    { # trigger at 18:00 no matter what
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
        { # if anybody is still there
          condition = "state";
          entity_id = "group.team";
          state = "not_home";
        }
      ];
    };
  }
]
