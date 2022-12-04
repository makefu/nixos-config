{ lib, ... }:
#uses:
# notify.signal
# binary_sensor.badezimmer_fenster_contact
# binary_sensor.dusche_fenster_contact
let
  hlib = import ../lib;
  say = hlib.say.office;
  draussen = "sensor.wohnzimmer_temp_temperature";
  draussen_diff = "sensor.unterschied_draussen_drinnen";
  draussen_heiss = 23;
  min = 20;
  fenster_offen = name: entity:
    { alias = "${name} seit ${toString min} Minuten offen";
      trigger = [
          {
            platform = "state";
            entity_id = entity;
            to = "on";
            for.minutes = min;
          }
      ];
      condition = [
      ];
      action =
      [
        {
          service = "notify.signal_home";
          data_template = {
            message = "${name} seit ${toString min} Minuten offen und draussen ist es gerade {{states.sensor.dark_sky_temperature.state}}°C bei {{states.sensor.dark_sky_humidity.state}}% Luftfeuchte";
          };
        }
        {
          service = "input_boolean.turn_on";
          target.entity_id = "input_boolean.${lib.toLower name}_lang_offen";
        }
      ];
    };
  fenster_geschlossen_lang = name: entity:
    { alias = "${name} wieder geschlossen";
      trigger = [
          {
            platform = "state";
            entity_id = entity;
            to = "off";
            for.seconds = 10;
          }
        ];
      condition = [
        { condition = "state";
          entity_id = "input_boolean.${lib.toLower name}_lang_offen";
          state = "on";
        }
      ];
      action =
      [
        {
          service = "notify.signal_home";
          data = {
            message= "${name} ist wieder geschlossen, Danke!";
          };
        }
        {
          service = "input_boolean.turn_off";
          target.entity_id = "input_boolean.${lib.toLower name}_lang_offen";
        }
      ];
    };
in {
  services.home-assistant.config = {
    template = [
      { sensor = {
        name = "Unterschied Draussen Drinnen";
        unit_of_measurement = "°C";
        state = ''
          {% set inside = states("${draussen}") | float | round(2) -%}
          {% set outside = states("sensor.dark_sky_temperature") | float | round(2) -%}
          {{ ((outside - inside) | round(1) )}}'';
        };
      }
    ];
    sensor = [
      { platform = "season"; type = "meteorological";}
    ];

    input_boolean = {
      badezimmerfenster_lang_offen.name = "Badezimmer lange offen";
      duschfenster_lang_offen.name = "Duschfenster lange offen";
      ist_sommer = {
        name = "Es ist Sommer";
        initial = false; # TODO
      };
    };

    automation = [
      (fenster_geschlossen_lang "Badezimmerfenster" "binary_sensor.badezimmer_fenster_contact")
      (fenster_geschlossen_lang "Duschfenster" "binary_sensor.dusche_fenster_contact")

      (fenster_offen "Badezimmerfenster" "binary_sensor.badezimmer_fenster_contact")
      (fenster_offen "Duschfenster" "binary_sensor.dusche_fenster_contact")

      { alias = "Draussen ist wieder kaelter";
        trigger = [
            {
              platform = "numeric_state";
              entity_id = draussen_diff;
              below = 0;
              for.minutes = 20;
            }
        ];
        condition = [
          { condition = "numeric_state";
            entity_id = draussen;
            above = draussen_heiss;
          }
        ];
        action = (say "Draussen ist es endlich kühler, jetzt kann man die Fenster auf machen");
      }
      { alias = "Draussen ist zu warm";
        trigger = [
            {
              platform = "numeric_state";
              entity_id = draussen_diff;
              above = 0;
              for.minutes = 20;
            }
        ];
        condition = [
          { condition = "numeric_state";
            entity_id = draussen;
            above = draussen_heiss;
          }
        ];
        action = (say "Draussen wird es jetzt zu warm, besser das fenster schliessen");
      }
    ];
  };
}
