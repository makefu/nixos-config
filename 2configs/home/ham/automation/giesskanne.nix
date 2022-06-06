# uses:
#  switch.crafting_giesskanne_relay
let
  cam = {
    name = "chilicam";
    camera = "camera.espcam_02";
    light = "light.espcam_02_light";
    seconds = 90; # default shutoff to protect the LED from burning out
  };
  seconds = 60*5; # time for giesskanne - 5 minutes
  pump = "switch.arbeitszimmer_giesskanne_relay";
  light = "switch.terrasse_plug_relay";

  # sensor = "sensor.statistics_for_sensor_crafting_brotbox_soil_moisture";
in
{
  services.home-assistant.config =
  {
    #sensor = map ( entity_id: {
    #    platform = "statistics";
    #    name = "Statistics for ${entity_id}";
    #    inherit entity_id;
    #    max_age.minutes = "60";
    #    sampling_size = 1000;
    #  }) [ "sensor.crafting_brotbox_soil_moisture" ];

    automation =
    [

      ##### brotbox
      { alias = "Water the plant for ${toString seconds} seconds and turn on the light";
        trigger = [
          { # trigger at 23:15 no matter what
            # TODO: retry or run only if switch.wasser is available
            platform = "sun";
            event = "sunrise";
          }
        ];
        action =
        [

          { # now turn on the pumping services
            # i do not start hte pump and light before the snapshot because i do
            # not know how long it takes (do not want to water the plants for too long)
            service = "homeassistant.turn_on";
            entity_id =  [ pump light ];
          }
          { delay.seconds = seconds; }
          {
            service = "homeassistant.turn_off";
            entity_id =  [ pump cam.light ];
          }
          { # TODO: we could also create a recording with camera.record
            service = "camera.snapshot";
            data = {
              entity_id = cam.camera;
              # TODO: create /var/lib/hass/cam/ - now being done manually
              filename = "/var/lib/hass/cam/${cam.name}_{{ now().strftime('%Y%m%d-%H%M%S') }}.jpg";
            };
          }
        ];
      }
      { alias = "Turn off the light at sunset";
        trigger = [
          {
            platform = "sun";
            event = "sunset";
            # offset = "+02:00:00";
          }
        ];
        action =
        [
          {
            service = "homeassistant.turn_off";
            entity_id =  [ light ];
          }
        ];
      }

      { alias = "Always turn off water after ${toString (seconds * 2)}s";
        trigger = [
          {
            platform = "state";
            entity_id = pump;
            to = "on";
            for.seconds = seconds*2;
          }
        ];
        action =
        [
          {
            service = "homeassistant.turn_off";
            entity_id =  [ pump ];
          }
        ];
      }
    ];
  };
}
