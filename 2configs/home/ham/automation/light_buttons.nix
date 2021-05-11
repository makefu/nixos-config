
let
  btn_state = light: btn: halfbright:
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
  turn_off_all = btn:
  {
    alias = "Turn of all lights via ${btn} double click";
    trigger = {
      platform = "state";
      entity_id = "sensor.${btn}_click";
      to = "double";
    };
    action = {
      service = "light.turn_off";
      entity_id = "all";
    };
  };
in {
  services.home-assistant.config.automation = [
    # (btn_state "light.arbeitszimmerbeleuchtung" "arbeitszimmer_btn1")
    (btn_state "light.schlafzimmer_komode_osram" "schlafzimmer_btn2" 128)
    # (btn_state "light.wohnzimmerbeleuchtung" "wohnzimmer_btn3")
    (turn_off_all "schlafzimmer_btn2")
  ];
}
