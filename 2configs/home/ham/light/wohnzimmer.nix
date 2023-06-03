let
  wohnzimmerbeleuchtung = [
    "light.wohnzimmer_komode_osram_light"
    "light.wohnzimmer_schrank_osram_light"
  ];
  wohnzimmer_deko = [
    "light.wohnzimmer_fernseher_led_strip" # led um fernseher
    "light.wohnzimmer_lichterkette_led_strip" # led um fernsehwand
    "light.wohnzimmer_fenster_lichterkette_licht" # led um fenster
  ];
in {
  imports = [ ./tint_wohnzimmer.nix ];
  services.home-assistant.config.scene = [
    { name = "Wohnzimmer Abendlicht";
      id = "living_room_evening";
      entities = {
        "light.wohnzimmer_komode_osram_light" = {
          state = "on";
          brightness = 128;
        };
        "light.wohnzimmer_schrank_osram_light" = {
          state = "on";
          brightness = 128;
        };
        "light.wohnzimmer_fenster_lichterkette_licht"  = "on";
        "light.wohnzimmer_fernseher_led_strip" = {
          state = "on";
        };
      };

    }
  ];
  services.home-assistant.config.wled = {};
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
    {
      platform = "group";
      name = "living_room_lights";
      entities = wohnzimmerbeleuchtung ++ wohnzimmer_deko;
    }
  ];
}

#   trigger.to_state.attributes.action_group:
#       1: 18388
#       2: 18389
#       3: 18390
