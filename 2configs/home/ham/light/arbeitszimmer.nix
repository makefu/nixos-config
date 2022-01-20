let
  arbeitszimmer_deko = [
    "light.led_wand"
    "light.box_led_status"
    "light.arbeitszimmer_led1_led_strip" # LED-Kreis in cube
  ];
  arbeitszimmerbeleuchtung = [
    "light.arbeitszimmer_schrank_dimmer"
    "light.arbeitszimmer_kerze"
    "light.arbeitszimmer_pflanzenlicht"
  ];
in {
  imports = [ ./tint_arbeitszimmer.nix ];

  services.home-assistant.config.light = [
    {
      platform = "group";
      name = "Arbeitszimmerbeleuchtung";
      entities = arbeitszimmerbeleuchtung;
    }
    {
      platform = "group";
      name = "Arbeitszimmer Deko";
      entities = arbeitszimmer_deko;
    }
    { platform = "switch";
      name = "Arbeitszimmer Pflanzenlicht";
      entity_id = "switch.arbeitszimmer_stecker1";
    }
  ];
  services.home-assistant.config.automation = [
  ];
}
