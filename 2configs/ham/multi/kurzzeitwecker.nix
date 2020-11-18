# Provides:
#   timer
#   automation
#   script

# Needs:
#  sensor.zigbee_btn1_click
#  notify.telegrambot
let
  button = "sensor.zigbee_btn2_click";
in
{
  services.home-assistant.config = {
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
                {% set r = state_attr('timer.kurzzeitwecker', 'remaining') ~ '-0000' %}
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
            data.duration = "00:05:00";
          }
          {
            service = "notify.telegrambot";
            data.message = "Timer gestartet {{state_attr('timer.kurzzeitwecker', 'remaining') }}, verbleibend ";
          }
        ];
      }
      {
        alias = "Add Timer 5min";
        trigger = {
          platform = "state";
          entity_id = button;
          to =  "single";
        };
        condition =
            { condition = "state";
              entity_id = "timer.kurzzeitwecker";
              state =  "active";
            };

        action = [
          { service = "homeassistant.turn_on";
            entity_id =  "script.add_5_minutes_to_kurzzeitwecker";
          }
          {
            service = "notify.telegrambot";
            data.message = ''Timer um 5 minuten verlängert, {{ state_attr('timer.kurzzeitwecker', 'remaining') | truncate(9,True," ") }} verbleibend '';
          }
        ];
      }
      {
        alias = "Stop timer on double click";
        trigger = [
          {
            platform = "state";
            entity_id = button;
            to =  "double";
          }
          {
            platform = "state";
            entity_id = button;
            to =  "triple";
          }
        ];
        condition =
        {
          condition = "state";
          entity_id = "timer.kurzzeitwecker";
          state =  "active";
        };

        action = [
          {
            service = "timer.cancel";
            entity_id =  "timer.kurzzeitwecker";
          }
          {
            service = "notify.telegrambot";
            data.message = "Timer gestoppt, abgebrochen";
          }
        ];
      }
      {
        alias = "Timer Finished";
        trigger = {
          platform = "event";
          event_type = "timer.finished";
          event_data.entity_id = "timer.kurzzeitwecker";
        };
        action = [
          {
            service = "notify.telegrambot";
            data.message = "Timer beendet";
          }
        ];
      }
    ];
  };
}
