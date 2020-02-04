{lib,...}: [
  { platform = "darksky";
    api_key = lib.removeSuffix "\n"
      (builtins.readFile <secrets/hass/darksky.apikey>);
    language = "de";
    monitored_conditions = [
      "summary" "icon"
      "nearest_storm_distance" "precip_probability"
      "precip_intensity"
      "temperature" # "temperature_high" "temperature_low"
      "apparent_temperature"
      "hourly_summary" # next 24 hours text
      "humidity"
      "pressure"
      "uv_index"
    ];
    units =  "si" ;
    scan_interval = "00:30:00";
  }
  { platform = "luftdaten";
    name = "Muehlhausen";
    show_on_map = true;
    sensor_id = "679";
    sensors.monitored_conditions = [ "P1" "P2" ];
  }
  ]
