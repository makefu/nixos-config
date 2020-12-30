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
      (rf_toggle "401151" "light.wohnzimmer_stehlampe_osram")            # B
      (rf_toggle "401451" "light.wohnzimmer_komode_osram")               # C
      (rf_toggle "401511" "light.wohnzimmer_schrank_osram")              # D

                                                                        # OFF Lane
      (rf_turn_off "400554" "all")                                       # A
      (rf_toggle "401154" "light.wohnzimmer_fenster_lichterkette_licht") # B
      (rf_toggle "401454" "light.wohnzimmer_fernsehwand_led")            # C
      # (rf_toggle "401514" "")   # D
  ];
    # "400554" # A OFF
    # "401154" # B OFF
    # "401454" # C OFF
    # "401514" # D OFF
}
