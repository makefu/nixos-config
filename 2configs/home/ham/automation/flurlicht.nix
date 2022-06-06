let
  nachtlicht = [ "light.flur_statuslight" "light.wohnzimmer_status_led" ];

  # flurlicht an
  lightcond = name: conditions: rgb_color: brightness:
  {
    inherit conditions;
    sequence = {
      service = "light.turn_on";
      target.entity_id = nachtlicht;
      data = {
        inherit rgb_color brightness;
      };
    };
  };
in
{
  services.home-assistant.config.automation =
  [
    { alias = "Nachtlicht trigger";
      trigger = [
        { platform = "sun"; event = "sunset"; }
        { platform = "sun"; event = "sunrise"; }
        { platform = "state"; entity_id = [
            "calendar.kehrwoche_kehrwoche"
            "binary_sensor.badezimmer_fenster_contact"
            "binary_sensor.dusche_fenster_contact"
          ];
        }
      ];
      action =
      [
        { choose = [
              (lightcond "Badezimmer Fenster Auf"
                { condition = "state"; entity_id = "binary_sensor.badezimmer_fenster_contact"; state =  "on"; }
                [ 64 207 255 ] 255 # helblau
              )
              (lightcond "Duschenster auf"
                { condition = "state"; entity_id = "binary_sensor.dusche_fenster_contact"; state =  "on"; }
                [ 64 207 255 ] 255 # helblau
              )
              (lightcond "Nachtlicht"
                { condition = "state"; entity_id = "sun.sun"; state =  "below_horizon"; }
                [ 255 190 0 ] 90 # red
              )
              (lightcond "Kehrwoche"
                { condition = "state"; entity_id = "calendar.kehrwoche_kehrwoche"; state =  "on"; }
                [ 204 0 255 ] 128 # pink
              )
            ];
          default = {
            service = "light.turn_off";
            entity_id = nachtlicht;
          };
        }
      ];
    }
  ];
}
