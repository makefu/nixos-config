let
  licht = "light.flur_statuslight";
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
            rgbw_color = [ 255 190 0 0 ]; # ein dunkles rot
            #effect = "None";
          };
        }
      ];
    }
    { alias = "Nachtlicht in Flur aus";
      trigger = {
        platform = "sun";
        event = "sunrise";
      };
      action =
      [
        {
          service = "light.turn_off";
          entity_id = licht;
        }
      ];
    }
  ];
}
