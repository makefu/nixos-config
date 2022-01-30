# This module maps the RF433 Remote Control to zigbee and wifi lights
let
  rf_turn_off = code: light:
  {
    alias = "Turn off ${light} via rf code ${code}";
    trigger = {
      platform = "event";
      event_type = "esphome.rf_code_received";
      event_data.code = code;
    };
    action = {
      service = "light.turn_off";
      data.entity_id = light;
    };
  };
  rf_turn_on = code: light:
  {
    alias = "Turn on ${light} via rf code ${code}";
    trigger = {
      platform = "event";
      event_type = "esphome.rf_code_received";
      event_data.code = code;
    };
    action = {
      service = "light.turn_on";
      data.entity_id = light;
    };
  };
  rf_state = code: light: halfbright:
  let
    maxbright = 255;
    transition = 0.2; # seconds
  in
  # this function implements a simple state machine based on the state and brightness of the light (light must support brightness
  {
    alias = "Cycle through states of ${light} via rf code ${code}";
    trigger = {
      platform = "event";
      event_type = "esphome.rf_code_received";
      event_data.code = code;
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
  }
;
  rf_toggle = code: light:
  {
    alias = "Toggle ${light} via rf code ${code}";
    trigger = {
      platform = "event";
      event_type = "esphome.rf_code_received";
      event_data.code = code;
    };
    action = {
      service = "light.toggle";
      data.entity_id = light;
    };
  };
in
{
  services.home-assistant.config.automation = [
      (rf_toggle "400551" "light.wohnzimmer_fernseher_led_strip")        # A
      (rf_state "401151" "light.wohnzimmer_stehlampe_osram" 128)            # B
      (rf_state "401451" "light.wohnzimmer_komode_osram" 128)               # C
      (rf_state "401511" "light.wohnzimmer_schrank_osram" 128)              # D

                                                                        # OFF Lane
      (let code = "400554"; in {
        alias = "Turn off living room light via rf code ${code}"; # A
        trigger = {
          platform = "event";
          event_type = "esphome.rf_code_received";
          event_data.code = code;
        };
        action = {
          service = "light.turn_off";
          data.entity_id = [
            "light.wohnzimmer_fernseher_led_strip" "light.wohnzimmer_stehlampe_osram"
            "light.wohnzimmer_komode_osram" "light.wohnzimmer_schrank_osram"
            "light.wohnzimmer_fenster_lichterkette_licht" "light.wled"
          ];
        };
      })

      (rf_toggle "401154" "light.wohnzimmer_fenster_lichterkette_licht") # B
      (rf_toggle "401454" "light.wohnzimmer_fernsehwand_led")            # C
      # (rf_toggle "401514" "")   # D
  ];
    # "400554" # A OFF
    # "401154" # B OFF
    # "401454" # C OFF
    # "401514" # D OFF
}
