# provides:
#   switch
#   automation
#   binary_sensor
#   sensor
#   input_select
#   timer
let
  inherit (import ../lib) esphome;
  sonoff_s20 = host: {
    sensor = [
      (esphome.ip { inherit host;})
      (esphome.wifi { inherit host;})
      (esphome.temp { inherit host;})
      (esphome.hum { inherit host;})
    ];
    binary_sensor = [
      (esphome.btn { inherit host;})
    ];
    light = [
      (esphome.monoled { inherit host;})
    ];
    switch = [
      (esphome.relay { inherit host;})
      (esphome.restart { inherit host;})
    ];
  };
  dusche = sonoff_s20 "dusche_plug";
  schlafzimmer = sonoff_s20 "schlafzimmer_plug";
in {
  sensor = [
    (esphome.pressure {host = "dusche_plug";})
  ]
  ++ dusche.sensor
  ++ schlafzimmer.sensor;
  binary_sensor =
     dusche.binary_sensor
  ++ schlafzimmer.binary_sensor;
  light =
     dusche.light
  ++ schlafzimmer.light;
  switch =
     dusche.switch
  ++ schlafzimmer.switch;
}
