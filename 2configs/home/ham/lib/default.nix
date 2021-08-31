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
        service = "media_player.turn_on";
        data.entity_id = entity;
      }
      {
        service = "media_player.play_media";
        data = {
          entity_id = entity;
          media_content_type = "playlist";
          media_content_id = "ansage";
        };
      }
      {
        service = "media_player.turn_on";
        data.entity_id = entity;
      }
      { delay.seconds = 8; }
      {
        service = "tts.say";
        entity_id =  entity;
        data_template = {
          inherit message;
          language = "de";
        };
      }
    ];
  in
  {
    firetv = message: tts {
      inherit message;
      entity = "firetv";
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
