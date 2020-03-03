# provides:
#  light
#  automation
#  binary_sensor
let
  hlib = (import ../lib);
  tasmota = hlib.tasmota;
in
{
  binary_sensor = [
    (tasmota.motion { name = "Flur Bewegung"; host = "flurlicht";})
  ];
  light = [ (tasmota.rgb { name = "Flurlicht"; host = "flurlicht";} ) ];
  automation = [
    { alias = "Dunkel bei Sonnenuntergang";
      trigger = {
        platform = "sun";
        event = "sunset";
        # offset: "-00:45:00"
      };
      action = [
        {
          service= "light.turn_on";
          data = {
            entity_id= "light.flurlicht";
            # rgb_color = [ 0,0,0 ]; <-- TODO default color
            brightness_pct = 15;
          };
        }
        {
          service= "light.turn_off";
          entity_id= "light.flurlicht";
        }
      ];
    }
    { alias = "Hell bei Sonnenaufgang";
      trigger = {
        platform = "sun";
        event = "sunrise";
        # offset: "-00:00:00"
      };
      action = [
        {
          service= "light.turn_on";
          data = {
            entity_id= "light.flurlicht";
            brightness_pct = 85;
          };
        }
        {
          service= "light.turn_off";
          entity_id= "light.flurlicht";
        }
      ];
    }
  ];
}
