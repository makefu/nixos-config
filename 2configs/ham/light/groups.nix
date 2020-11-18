let
  arbeitszimmer_licht = [
    "light.led_wand"
    "light.arbeitszimmer_led1_led_strip" # LED-Kreis in cube
    "light.arbeitszimmer_flur_osram_light"
    "light.arbeitszimmer_schrank_dimmer_light"
    "light.arbeitszimmer_schrank_osram_light"
  ];
  wohnzimmer_licht = [
    "light.wohnzimmer_fernseher_led_strip" # led um fernseher
    "light.wohnzimmer_komode_osram_light"
    "light.wohnzimmer_schrank_osram_light"
    "light.wohnzimmer_stehlampe_osram_light"
  ];
  schlafzimmer_licht = [
    "schlafzimmer_komode_osram_light"
  ];
in {
  services.home-assistant.config.light = [
    {
      platform = "group";
      name = "Arbeitszimmer Lichter";
      entities = arbeitszimmer_licht;
    }
    {
      platform = "group";
      name = "Wohnzimmer Lichter";
      entities = wohnzimmer_licht;
    }
    {
      platform = "group";
      name = "Schlafzimmer Lichter";
      entities = schlafzimmer_licht;
    }
    {
      platform = "group";
      name = "Alle Lichter";
      entities = arbeitszimmer_licht ++ wohnzimmer_licht ++ schlafzimmer_licht;
    }
  ];
}
