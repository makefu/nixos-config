{ lib, ... }:
# uses:
# 
let
  at_work = "input_boolean.felix_at_work";
  dice_action = "sensor.arbeitszimmer_cube_action";
  project_sensor = "sensor.felix_project";
  hlib = import ../lib;
  say = hlib.say.office;
  sides = [ "BDK" "LBS6" "random" "BNO" "CyberShield" "ILBS" ];
  hist_stat = state: {
      platform = "history_stats";
      name = "Felix Project ${state}";
      entity_id =  project_sensor;
      inherit state;
      type = "time";
      start = "{{ now().replace(hour=0, minute=0, second=0) }}";
      end = "{{ now() }}";
  };

in
  {
    services.home-assistant.config.sensor = map hist_stat (sides ++ ["not at work" "unknown"]);
    services.home-assistant.config.automation = [
      { alias = "Felix Project Change";
        trigger =
        {
          platform = "state";
          entity_id = project_sensor;
          # ignore login and log out
          not_from = [ "not at work" ];
          not_to = [ "not at work" ];
        };

        action = (say "Wechsel auf Projekt {{ trigger.to_state.state }}");
      }
    ];
    services.home-assistant.config.template = [
      {
        trigger = [
          {
            platform = "state";
            entity_id = at_work;
          }
          {
            platform = "state";
            attribute = "side";
            entity_id = dice_action;
            not_from = "";
          }
        ];
        sensor = [
          { name = "Felix Project";
            state = ''
              {% set at_work = states('${at_work}') == 'on' %}
              {% set side = state_attr('${dice_action}','side') %}
              {% if not at_work %}not at work
              '' + (lib.concatImapStringsSep "\n" (i: project: 
              "{% elif side == ${toString (i - 1)} %}${project}") sides) + 
              ''
              {% else %}unknown
              {% endif %}
              '';
          }
        ];
      }
    ];
  }
