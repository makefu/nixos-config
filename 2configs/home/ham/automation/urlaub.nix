# uses:
#  light.wohnzimmer_schrank_osram
#  light.wohnzimmer_fernseher_led_strip
#  "all" lights

let
  schranklicht = "light.wohnzimmer_schrank_osram";
  weihnachtslicht = "light.wohnzimmer_fenster_lichterkette_licht";
  fernsehlicht = "light.wled";
  final_off = "00:37";

  turn_on = entity_id: at:
  { alias = "Turn on ${entity_id} at ${at}";
    trigger = [
      { platform = "time"; inherit at; }
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
      (turn_on schranklicht "17:30")
      (turn_on weihnachtslicht "17:30")
      (turn_on fernsehlicht "19:00")

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
