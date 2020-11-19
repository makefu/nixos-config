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
      entity = light;
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
      entity = "light.alle_lichter";
    };
  };
in {
  services.home-assistant.config.automation = [
    (toggle "light.wohnzimmer_lichter" "btn3")
    (turn_off_all "btn3")
  ];
}
