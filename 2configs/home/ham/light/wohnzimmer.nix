let
  wohnzimmerbeleuchtung = [
    "light.wohnzimmer_komode_osram_light"
    "light.wohnzimmer_schrank_osram_light"
  ];
  wohnzimmer_deko = [
    "light.wohnzimmer_fernseher_led_strip" # led um fernseher
    "light.wohnzimmer_lichterkette_led_strip" # led um fernsehwand
    "light.kinderzimmer_lichterkette_licht" # led um fenster
  ];
in {
  services.home-assistant.config.light = [
    {
      platform = "group";
      name = "Wohnzimmerbeleuchtung";
      entities = wohnzimmerbeleuchtung;
    }
    {
      platform = "group";
      name = "Wohnzimmer Deko";
      entities = wohnzimmer_deko;
    }
  ];
}
