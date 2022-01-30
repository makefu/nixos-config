let
  licht = [ "light.flur_statuslight" "light.wohnzimmer_status_led" ];
  kehrwoche_color = [ 204 0 255 ]; # pink
  nachtlicht_color = [ 255 190 0 ]; # ein dunkles rot
in
{
  services.home-assistant.config.automation =
  [
    { alias = "Nachtlicht im Flur an";
      trigger = {
        platform = "sun";
        event = "sunset";
      };
      action =
      [
        {
          service = "light.turn_on";
          target.entity_id = licht;
          data = {
            brightness = 87;
            rgb_color = nachtlicht_color;
            #effect = "None";
          };
        }
      ];
    }
    { alias = "Nachtlicht in Flur aus, Kehrwoche an";
      trigger = {
        platform = "sun";
        event = "sunrise";
      };
      action =
      [
        { choose = [
          {
            conditions = {
              condition = "state";
              entity_id = "calendar.kehrwoche_kehrwoche";
              state =  "on";
            };
            sequence = {
              service = "light.turn_on";
              target.entity_id = licht;
              data = {
                brightness = 190;
                rgb_color = kehrwoche_color; # pink
              };
            };
          }];
          default = {
              service = "light.turn_off";
              entity_id = licht;
            };
        }
      ];
    }
  ];
}
