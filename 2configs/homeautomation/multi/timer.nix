# Provides:
#   timer
#   automation
#   script

# Needs:
#  sensor.zigbee_btn1_click
#  notify.telegrambot
let
  button = "sensor.zigbee_btn1_click";
in {
  timer.kurzzeitwecker =
  {
    name = "Zigbee Kurzzeitwecker";
    duration = 300;
  };
    script.add_5_minutes_to_kurzzeitwecker =
    {
        alias = "Add 5 minutes to kurzzeitwecker";
        sequence = [
          { service = "timer.pause";
          entity_id = "timer.kurzzeitwecker";
        }
        { service = "timer.start";
        data_template = {
          entity_id = "timer.kurzzeitwecker";
          duration = ''
            {% set r = state_attr('timer.wecker', 'remaining') ~ '-0000' %}
            {% set t = strptime(r, '%H:%M:%S.%f%z') %}
            {{ (as_timestamp(t) + 300) | timestamp_custom('%H:%M:%S', false) }}
          '';
        };
      }
    ];
  };
  automation =
  [
    {
      alias = "Start Timer 5min";
      trigger = {
        platform = "state";
        entity_id = button;
        to =  "single";
      };
      condition =
          { condition = "state";
            entity_id = "timer.kurzzeitwecker";
            state =  "idle";
          };

      action = [
        { service = "timer.start";
          entity_id =  "timer.kurzzeitwecker";
          duration = "00:05:00";
        }
        {
          service = "notify.telegrambot";
          data = {
            title = "Timer gestartet";
            message = "Timer auf 5 minuten gestellt";
          };
        }
      ];
    }
    {
      alias = "Start Timer 10min";
      trigger = {
        platform = "state";
        entity_id = button;
        to =  "double";
      };
      condition =
      {
        condition = "state";
        entity_id = "timer.kurzzeitwecker";
        state =  "idle";
      };
      action =
      [
        {
          service = "timer.start";
          entity_id =  "timer.kurzzeitwecker";
          duration = "00:10:00";
        }
        {
          service = "notify.telegrambot";
          data = {
            title = "Timer gestartet";
            message = "Timer auf 10 minuten gestellt";
          };
        }
      ];
    }
    {
      alias = "Stop timer on triple click";
      trigger =
      {
        platform = "state";
        entity_id = button;
        to =  "triple";
      };
      condition =
      {
        condition = "state";
        entity_id = "timer.kurzzeitwecker";
        state =  "active";
      };

      action = [
        {
          service = "timer.stop";
          entity_id =  "timer.kurzzeitwecker";
        }
        {
          service = "notify.telegrambot";
          data = {
            title = "Timer gestoppt";
          };
        }
      ];
    }
  ];
}
