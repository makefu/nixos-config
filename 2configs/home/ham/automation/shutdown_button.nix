let
  btn = "sensor.arbeitszimmer_btn1_action";
  lib = import ../lib;
  say = lib.say.living_room;

  all_lights = [
    # Wohnzimmer
    "light.wled"
    "light.wled_2"
    "light.wohnzimmer_komode_osram"
    "light.wohnzimmer_schrank_osram"
    "light.wohnzimmer_fenster_lichterkette_licht"

    # Arbeitszimmer
    "light.wled_3"
    "light.wled_4"
    "light.arbeitszimmer_schrank_dimmer"
    "light.arbeitszimmer_pflanzenlicht"
    "light.wohnzimmer_stehlampe_osram"

    # Keller
    "light.keller_osram"
  ];
  all_media_player = [
    "media_player.living_room"
    "media_player.office"
    "media_player.bedroom"

  ];
in {
  services.home-assistant.config.automation =
    [
      { alias = "Wohnung shutdown single click";
      trigger = [
        {
          platform = "state";
          entity_id = btn;
          to = "single";
        }
      ];
      condition = [ ];
      action = (say "Alles Aus" )++ [
        {
          service = "light.turn_off";
          target.entity_id = all_lights;
        }
        { service = "media_player.media_stop";
          target.entity_id = all_media_player;
        }
        { service = "script.turn_on";
          target.entity_id = "script.alle_heizungen_aus";
        }
      ];
    }
  ];
}
