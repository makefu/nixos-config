# uses:
#  light.wohnzimmer_schrank_osram
#  light.wohnzimmer_fernseher_led_strip
#  "all" lights

let
  schranklicht = [
    "light.wohnzimmer_schrank_osram"
    "light.wohnzimmer_komode_osram"
  ];
  weihnachtslicht = "light.wohnzimmer_fenster_lichterkette_licht";
  fernsehlicht = "light.wled";

  all_lights = [
    schranklicht weihnachtslicht fernsehlicht 
    # extra lights to also turn off
    # wohnzimmer
    "light.wohnzimmer_komode_osram"
    "light.wohnzimmer_stehlampe_osram"
    # arbeitszimmer
    "light.wled_4"
    "light.arbeitszimmer_schrank_dimmer"
    "light.arbeitszimmer_pflanzenlicht"
  ];

  final_off = "00:37";

  turn_on = entity_id: offset:
  # negative offset => before sunset
  { alias = "Turn on ${toString entity_id} at sunset ${offset}";
    trigger = [
      { platform = "sun"; event = "sunset"; inherit offset; }
    ];
    action =
    [
      { service = "light.turn_on"; inherit entity_id; }
    ];
  };
in
{
  services.home-assistant.config =
  {
    automation =
    [
      (turn_on schranklicht "-00:30:00")
      #(turn_on weihnachtslicht "-00:30:00")
      (turn_on fernsehlicht "-00:00:00")

      { alias = "Always turn off the urlaub lights at ${final_off}";
        trigger = [
          { platform = "time"; at = final_off; }
        ];
        action =
        [
          {
            service = "light.turn_off";
            entity_id =  [ schranklicht weihnachtslicht fernsehlicht ];
          }
        ];
      }
    ];
  };
}
