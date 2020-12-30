# light.wohnzimmerbeleuchtung
# light.wohnzimmer_deko
# light.arbeitszimmerbeleuchtung
# light.arbeitszimmer_deko
# light.schlafzimmerbeleuchtung

let
  toggle = light: btn:
  {
    alias = "Toggle Light ${light} via ${btn}";
    trigger = {
      platform = "state";
      entity_id = "sensor.${btn}_click";
      to = "single";
    };
    action = {
      service = "light.toggle";
      data.entity_id = light;
      data.transition = 0;
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
    (toggle "light.arbeitszimmerbeleuchtung" "arbeitszimmer_btn1")
    (toggle "light.schlafzimmerbeleuchtung" "schlafzimmer_btn2")
    (toggle "light.wohnzimmerbeleuchtung" "wohnzimmer_btn3")
    (turn_off_all "arbeitszimmer_btn1")
    (turn_off_all "schlafzimmer_btn2")
    (turn_off_all "wohnzimmer_btn3")
  ];
}
