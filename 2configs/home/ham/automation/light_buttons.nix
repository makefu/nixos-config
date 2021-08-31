
let
  inherit (import ../lib) btn_cycle_light;
  turn_off_all = btn: #lights:
  {
    alias = "Turn of all lights via ${btn} double click";
    trigger = {
      platform = "state";
      entity_id = "sensor.${btn}_click";
      to = "double";
    };
    action = {
      service = "light.turn_off";
      #entity_id = lights;
      entity_id = "all";
    };
  };
in {
  services.home-assistant.config.automation = [
    # (btn_cycle_light "light.arbeitszimmerbeleuchtung" "arbeitszimmer_btn1")
    (btn_cycle_light "light.schlafzimmer_komode_osram" "schlafzimmer_btn2" 128)

    (btn_cycle_light "light.keller_osram" "keller_btn1" 128)
    # (btn_cycle_light "light.wohnzimmerbeleuchtung" "wohnzimmer_btn3")
    (turn_off_all "schlafzimmer_btn2" )
  ];
}
