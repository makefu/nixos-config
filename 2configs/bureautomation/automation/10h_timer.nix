[
  { alias = "start Felix 10h";
    trigger = {
      platform = "state";
      entity_id = "binary_sensor.redbutton";
      to = "on";
    };
    condition = {
      condition = "and";
      conditions = [
        {
          condition = "state";
          entity_id = "timer.felix_10h";
          state =  "idle";
        }
        {
          condition = "time";
          after   = "06:00:00";
          before  = "12:00:00";
        }
      ];
    };
    action = [
      { service = "timer.start";
        entity_id =  [ "timer.felix_10h" "timer.felix_8_30h" "timer.felix_7h" ] ;
      }
      { service = "homeassistant.turn_on";
        entity_id =  [
          "script.buzz_red_led_fast"
          "script.blitz_10s"
        ];
      }
      { service = "light.turn_on";
      data = {
          effect = "2";
          entity_id =  [ "light.status_felix" ];
        };
      }
    ];
  }

  { alias = "Disable Felix timer at button press";
    trigger = {
      platform = "state";
      entity_id = "binary_sensor.redbutton";
      to = "on";
    };
    condition = {
      condition = "and";
      conditions = [
        {
          condition = "state";
          entity_id = "timer.felix_10h";
          state =  "active";
        }
        {
          condition = "time";
          after = "12:00:00";
          before  = "22:00:00";
        }
      ];
    };
    action =
    [
      {
        service = "timer.cancel";
        entity_id =  [ "timer.felix_10h" "timer.felix_8_30h" "timer.felix_7h" ];
      }
      {
        service = "homeassistant.turn_on";
        entity_id =  [ "script.buzz_red_led_fast"  ];
      }
      {
        service = "homeassistant.turn_off";
        entity_id =  [ "light.status_felix"  ];
      }
    ];
  }

  {
    alias = "Genug gearbeitet Felix";
    trigger =
    {
      platform = "event";
      event_type = "timer.finished";
      event_data.entity_id = "timer.felix_7h";
    };
    action =
    [
      { service = "light.turn_on";
        data = {
          rgb_color= [0 255 0];
          # effect = "0";
          entity_id =  [ "light.status_felix" ];
        };
      }
    ];
  }

  {
    alias = "nun aber nach hause";
    trigger =
    {
      platform = "event";
      event_type = "timer.finished";
      event_data.entity_id = "timer.felix_8_30h";
    };
    action =
    [
      { service = "light.turn_on";
        data = {
          rgb_color= [255 255 0];
          # effect = "0";
          entity_id =  [ "light.status_felix" ];
        };
      }
    ];
  }

  {
    alias = "Zu lange Felix!";
    trigger =
    {
      platform = "event";
      event_type = "timer.finished";
      event_data.entity_id = "timer.felix_10h";
    };
    action =
    [
      # TODO: Pushbullet
      {
        service = "homeassistant.turn_on";
        entity_id =  [
          "script.buzz_red_led"
          "script.blitz_10s"
        ];
      }
      { service = "light.turn_on";
        data = {
          rgb_color= [255 0 0];
          effect = "0";
          entity_id =  [ "light.status_felix" ];
        };
      }
    ];
  }
]
