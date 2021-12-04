
let
  inherit (import ../lib) btn_cycle_light;
in {
  services.home-assistant.config.automation = [
    # (btn_cycle_light "light.arbeitszimmerbeleuchtung" "arbeitszimmer_btn1")
    (btn_cycle_light "light.schlafzimmer_komode_osram" "schlafzimmer_btn2" 128)
    {
      alias = "toggle keller";
      trigger = {
        platform = "state";
        entity_id = "sensor.keller_btn1_click";
        to = "single";
      };
      action = {
        service = "light.toggle";
        #entity_id = lights;
        data = {
          entity_id = "light.keller_osram";
          brightness = 255;
        };
      };
    }
    {
      alias = "low brightness keller with doubleclick";
      trigger = {
        platform = "state";
        entity_id = "sensor.keller_btn1_click";
        to = "double";
      };
      action = {
        service = "light.toggle";
        data = {
          entity_id = "light.keller_osram";
          brightness = 50;
        };
      };
    }
    # (btn_cycle_light "light.wohnzimmerbeleuchtung" "wohnzimmer_btn3")
    {
      alias = "Turn of all lights via schlafzimmer_btn2 double click";
      trigger = {
        platform = "state";
        entity_id = "sensor.schlafzimmer_btn2_click";
        to = "double";
      };
      action = {
        service = "light.turn_off";
        entity_id = "all";
      };
    }
  ];
}
