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
          service = "notify.firetv_wohnzimmer";
          data = {
            title = "${name} seit ${toString min} Minuten offen";
            message = "Bitte einmal checken ob das ok ist :)";
            data = {
              interrupt = 1;
              duration = 300;
            };
          };
        }
      ];
    };
in {
  services.home-assistant.config.automation = [
    (fenster_offen "Badezimmerfenster" "binary_sensor.badezimmer_fenster_contact")
    (fenster_offen "Duschfenster" "binary_sensor.dusche_fenster_contact")
  ];
}
