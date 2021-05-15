{ lib, ... }:
#uses:
# notify.signal
# binary_sensor.badezimmer_fenster_contact
# binary_sensor.dusche_fenster_contact
let
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
      action =
      [
        {
          service = "notify.signal_home";
          data = {
            message= "${name} seit ${toString min} Minuten offen\nBitte einmal checken ob das ok ist :)";
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
    input_boolean = {
      badezimmerfinester_lang_offen.name = "Badezimmer lange offen";
      duschfenster_lang_offen.name = "Duschfenster lange offen";
    };
    automation = [
      (fenster_geschlossen_lang "Badezimmerfenster" "binary_sensor.badezimmer_fenster_contact")
      (fenster_geschlossen_lang "Duschfenster" "binary_sensor.badezimmer_fenster_contact")
      (fenster_offen "Badezimmerfenster" "binary_sensor.badezimmer_fenster_contact")
      (fenster_offen "Duschfenster" "binary_sensor.dusche_fenster_contact")
    ];
  };
}
