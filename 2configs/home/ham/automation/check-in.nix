let
  button = "binary_sensor.arbeitszimmer_onebutton_button";
  light = "light.arbeitszimmer_onebutton_led";
  at_work = "input_boolean.felix_at_work";
  lib = import ../lib;
  say = lib.say.office;
in
{
  services.home-assistant.config.input_boolean.felix_at_work.name = "Felix auf Arbeit";
  services.home-assistant.config.automation =
    [
      { alias = "Push Check-in Button Felix with button";
        trigger = [
            {
              platform = "state";
              entity_id = button;
              to = "on";
              for.seconds = 1;
            }
        ];
        condition = [
        ];
        action =
          [
            { choose = [
                {
                  conditions = {
                    condition = "state";
                    entity_id = at_work;
                    state =  "off";
                  };
                  sequence = [
                    { service = "light.turn_on";
                      target.entity_id = light;
                      data.brightness = 200;
                    }
                    { service = "homeassistant.turn_on";
                      entity_id = at_work;
                    }
                  ] ++ (say "Willkommen auf Arbeit") ++
                  [
                    { service = "media_player.play_media";
                      data = {
                        media_content_id = "https://radio.lassul.us/radio.mp3";
                        media_content_type = "music";
                      };
                      target.entity_id = "media_player.office";
                    }
                  ];
                }
                {
                  conditions = {
                    condition = "state";
                    entity_id = at_work;
                    state =  "on";
                  };
                  sequence = [
                    { service = "light.turn_off";
                      target.entity_id = light;
                    }
                    { service = "homeassistant.turn_off";
                      entity_id = at_work;
                    }
                  ] ++ (say "Endlich ist Pappa fertig mit arbeit!");
                }
              ];
            }
          ];
      }
    ];
}
