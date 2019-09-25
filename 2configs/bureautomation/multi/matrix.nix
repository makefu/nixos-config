{ lib, ... }:
#matrix:
#  password: supersecurepassword
#  rooms:
#    - "#hasstest:matrix.org"
#  commands:
#    - word: my_command
#      name: my_command
let
  mom_room = "!kTQjvTQvfVsvfEtmth:thales.citadel.team";
in {
  matrix =
  {
    # secrets:
    # homeserver, username, password
    homeserver = "https://ext01.citadel.team";
    rooms = [
      mom_room
    ];
    commands = [
    {
      # alternative: expression for regexp
      word = "version";
      name = "version";
    }
    {
      word = "luftqualität";
      name = "luftqualitaet";
    }
  ];
  }  // (builtins.fromJSON (builtins.readFile
  <secrets/hass/citadel-bot.json>));
  automation = [
    {
      alias = "React to !version";
      trigger = {
        platform = "event";
        event_type = "matrix_command";
        event_data.command = "version";
      };
      action = {
        service = "notify.matrix_notify";
        data_template.message = "Running home-assistant {{states.sensor.current_version.state}}";
      };
    }
    {
      alias = "React to !luftqualität";
      trigger = {
        platform = "event";
        event_type = "matrix_command";
        event_data.command = "luftqualitaet";
      };
      action = {
        service = "notify.matrix_notify";
        data_template.message = "Temp: {{states.sensor.easy2_dht22_temperature.state_with_unit}} Hum:{{states.sensor.easy2_dht22_humidity.state_with_unit}} airquality:{{states.sensor.air_quality.state_with_unit}}";
      };
    }

  ];
  notify = [{
    name = "matrix_notify";
    platform = "matrix";
    default_room = mom_room;
  }];
}
