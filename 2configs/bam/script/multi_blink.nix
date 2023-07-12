{lib, ... }:
let
  # TODO: flash with different delay

  # let an entity blink for X times with  a delay of Y milliseconds
  flash_entity = { entity, delay ? 500, count ? 4, alias ?  "${entity}_blink_${toString count}_${toString delay}" }:
  {
    inherit alias;
    sequence = lib.flatten (builtins.genList (i: [
      { service = "homeassistant.turn_on";
        data.entity_id = entity;
      }
      { delay.milliseconds = delay; }
      { service = "homeassistant.turn_off";
        data.entity_id = entity;
      }
      { delay.milliseconds = delay; }
    ]
     ) count);
   };
in {
  services.home-assistant.config.script =
  {
    buzz_red_led = (flash_entity {
      entity = "light.redbutton_buzzer";
      alias = "Red Button Buzz";
      count = 4;
    });
    buzz_red_led_fast = (flash_entity {
      entity = "light.redbutton_buzzer";
      delay = 250;
      count = 2;
      alias = "Red Button Buzz fast";
    });
    blitz_10s = (flash_entity {
      entity = "switch.blitzdings";
      delay = 10000;
      count = 1;
      alias = "blitz for 10 seconds";
    });
    blasen_10s = (flash_entity {
      entity = "switch.frosch_blasen";
      delay = 10000;
      count = 1;
      alias = "blasen for 10 seconds";
    });
    blasen_30s = (flash_entity {
      entity = "switch.frosch_blasen";
      delay = 30000;
      count = 1;
      alias = "blasen for 30 seconds";
    });
    schlechteluft = (flash_entity {
      entity = "switch.bauarbeiterlampe";
      alias = "Schlechte Luft Lampe 5 secs";
      delay = 5000;
      count = 1;
    });
  };
}
