let
  prefix = "/ham";
in
{
  inherit prefix;
  say = let
    # returns a list of actions to be performed on an mpd to say something
    tts = { message, entity }:
    [
      {
        service = "sonos.snapshot";
        target.entity_id = entity;
      }
      {
        service = "tts.google_say";
        data = {
          entity_id =  entity;
          inherit message;
          language = "de";
        };
      }
      #{ wait_template = "{{ is_state('${entity}' , 'playing') }}";
      #  timeout = "00:00:02";
      #}
      #{ wait_template = "{{ not is_state('${entity}' , 'playing') }}";
      #  timeout = "00:01:00";
      #}
      { delay.seconds = 1; }
      { delay = ''
        {% set duration = states.${entity}.attributes.media_duration %}
        {% if duration > 0 %}
          {% set duration = duration - 1 %}
        {% endif %}
        {% set seconds = duration % 60 %}
        {% set minutes = (duration / 60)|int % 60 %}
        {% set hours = (duration / 3600)|int %}
        {{ "%02i:%02i:%02i"|format(hours, minutes, seconds)}}

        '';
      }
      {
        service = "sonos.restore";
        target.entity_id = entity;
      }
    ];
  in
  {
    living_room = message: tts {
      inherit message;
      entity = "media_player.living_room";
    };
    office = message: tts {
      inherit message;
      entity = "media_player.office";
    };
  };

  zigbee.prefix = "/ham/zigbee";

  btn_cycle_light = light: btn: halfbright:
  let
    maxbright = 255;
    transition = 0.2; # seconds
  in
  # this function implements a simple state machine based on the state and brightness of the light (light must support brightness
  {
    alias = "Cycle through states of ${light} via button ${btn}";
    trigger = {
      platform = "state";
      entity_id = "sensor.${btn}_click";
      to = "single";
    };
    action = {
      choose = [
        {
          # state 0: off to half
          conditions = {
            condition = "template";
            value_template = ''{{ states("${light}")  == "off" }}'';
          };
          sequence = [
            {
              service = "light.turn_on";
              data = {
                entity_id = light;
                brightness = halfbright;
              };
            }
          ];
        }
        {
          # state 1: half to full
          conditions = {
            condition = "template";
            value_template = ''{{ states('${light}')  == 'on' and ( ${toString (halfbright - 1)} <= state_attr("${light}","brightness") <= ${toString (halfbright + 1)})}}'';
          };
          sequence = [
            {
              service = "light.turn_on";
              data = {
                entity_id = light;
                brightness = maxbright;
              };
            }
          ];
        }
        {
          # state 2: full to off
          conditions =  {
            condition = "template";
            # TODO: it seems like the devices respond with brightness-1 , maybe off-by-one somewhere?
            value_template = ''{{ states("${light}")  == "on" and state_attr("${light}","brightness") >= ${toString (maxbright - 1)}}}'';
          };
          sequence = [
            {
              service = "light.turn_off";
              data = {
                entity_id = light;
              };
            }
          ];
        }
      ];
      # default: on to off
      # this works because state 0 checks for "state == off"
      default = [{
        service = "light.turn_off";
        data = {
          entity_id = light;
        };
      }];
    };
  };
}
