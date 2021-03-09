# uses:

let
  wohnzimmer = "light.wohnzimmer_fenster_lichterkette_licht";
  arbeitszimmer = "light.box_led_status";
  final_off = "01:00";

  turn_on = entity_id: at: extra:
  { alias = "Turn on ${entity_id} at ${at}";
    trigger = [
      { platform = "time"; inherit at; }
    ];
    action =
    [
      ({ service = "light.turn_on"; 
        data = {
          inherit entity_id; 

        } // extra;
        })
    ];
  };
in
{
  services.home-assistant.config =
  {
    automation =
    [
      # (turn_on wohnzimmer "17:30")
      (turn_on arbeitszimmer "9:00" { effect = "Slow Random Twinkle";})

      { alias = "Always turn off the lights at ${final_off}";
        trigger = [
          { platform = "time"; at = final_off; }
        ];
        action =
        [
          {
            service = "light.turn_off";
            entity_id =  [ wohnzimmer arbeitszimmer];
          }
        ];
      }
    ];
  };
}
