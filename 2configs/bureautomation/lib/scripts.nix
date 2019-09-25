{ lib, ... }:
{
  multi_flash = { entity, delays ? [ 500 ], alias ?  "${entity}_multi_flash_${toString (lib.length delays)}" }:
  {
    inherit alias;
    sequence = lib.flatten (builtins.map (delay: [
      { service = "homeassistant.turn_on";
        data.entity_id = entity;
      }
      { delay.milliseconds = delay; }
      { service = "homeassistant.turn_off";
        data.entity_id = entity;
      }
      { delay.milliseconds = delay; }
    ]
     ) delays);
   };
}
