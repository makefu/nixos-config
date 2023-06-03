
let
  inherit (import ../lib) btn_cycle_light;
  schlafzimmer_komode = "light.schlafzimmer_komode_osram";
  schlafzimmer_button = "sensor.schlafzimmer_btn2_click";
in {
  services.home-assistant.config.automation = [
    # (btn_cycle_light "light.arbeitszimmerbeleuchtung" "arbeitszimmer_btn1")

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
          brightness = 25;
        };
      };
    }
    # (btn_cycle_light "light.wohnzimmerbeleuchtung" "wohnzimmer_btn3")
    {
      alias = "Dim Toggle schlafzimmer komode";
      trigger = {
        platform = "state";
        entity_id = schlafzimmer_button;
        to = "single";
      };
      action = {
        service = "light.toggle";
        entity_id = schlafzimmer_komode;
        brightness = 1;
      };
    }
    {
      alias = "Bright Toggle schlafzimmer komode";
      trigger = {
        platform = "state";
        entity_id = schlafzimmer_button;
        to = "double";
      };
      action = {
        service = "light.toggle";
        entity_id = schlafzimmer_komode;
        brightness = 255;
      };
    }
  ];
}
