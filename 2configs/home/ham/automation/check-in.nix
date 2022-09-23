let
  button = "binary_sensor.arbeitszimmer_onebutton_button";
  light = "light.arbeitszimmer_onebutton_led";
  at_work = "input_boolean.felix_at_work";
  lib = import ../lib;
  say = lib.say.office;
in
{
  services.home-assistant.config.input_boolean.felix_at_work.name = "Felix auf Arbeit";
  services.home-assistant.config.timer.felix_at_work = {
    name = "Felix auf Arbeit Timer";
    duration = "10:00:00";
  };
  services.home-assistant.config.sensor = [
    {
      platform = "history_stats";
      name = "Felix at work today";
      entity_id =  "input_boolean.felix_at_work";
      state = "on";
      type = "time";
      start = "{{ now().replace(hour=0, minute=0, second=0) }}";
      end = "{{ now() }}";
    }
  ];
  services.home-assistant.config.script.start_office_radio.sequence =
    [
      { service = "media_player.play_media";
        data = {
          media_content_id = "http://radio.lassul.us:8000/radio.mp3";
          media_content_type = "music";
        };
        target.entity_id = "media_player.office";
      }
    ];
  services.home-assistant.config.automation =
    [
      { alias = "Zu lange Felix!";
      trigger =
      { platform = "event";
        event_type = "timer.finished";
        event_data.entity_id = "timer.felix_at_work";
      };

      condition =
      { 
        condition = "state";
        entity_id = at_work;
        state =  "off";
      };

      action = (say "Felix, die zehn Stunden sind um, aufhören jetzt");
      }
      { alias = "Turn off at work sensor";
        trigger = [
          { platform = "time"; at = "00:00:00"; }
        ];
        condition =
        { 
          condition = "state";
          entity_id = at_work;
          state =  "off";
        };
        action =
        [
          # felix forgot to stamp out ...
          {
            service = "homeassistant.turn_off";
            entity_id =  [ at_work ];
          }
        ];
      } 
      { alias = "Push Check-in Button Felix with button";
        trigger = [
            {
              platform = "state";
              entity_id = button;
              to = "on";
              for.seconds = 1;
            }
        ];
        condition = [
        ];
        action =
          [
            { choose = [
                {
                  conditions = {
                    condition = "state";
                    entity_id = at_work;
                    state =  "off";
                  };
                  sequence = [
                    { service = "light.turn_on";
                      target.entity_id = light;
                      data.brightness = 200;
                    }
                    { service = "homeassistant.turn_on";
                      entity_id = at_work;
                    }
                    { service = "timer.start";
                      entity_id =  [ "timer.felix_at_work" ] ;
                    }
                  ] ++ (say (builtins.readFile ./welcome.txt.j2)) ++
                  [
                    { service = "script.start_office_radio"; }
                  ];
                }
                {
                  conditions = {
                    condition = "state";
                    entity_id = at_work;
                    state =  "on";
                  };
                  sequence = [
                    { service = "light.turn_off";
                      target.entity_id = light;
                    }
                    { service = "homeassistant.turn_off";
                      entity_id = at_work;
                    }
                  ] ++ (say (builtins.readFile ./bye.txt.j2)) ++
                  [
                    { service = "timer.stop";
                      entity_id =  [ "timer.felix_at_work" ] ;
                    }
                  ];
                }
              ];
            }
          ];
      }
    ];
}
