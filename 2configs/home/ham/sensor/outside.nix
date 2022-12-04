{lib,...}:

{
  services.home-assistant.config.sensor =
  [
    { platform = "darksky";
      api_key = "!secret darksky";
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
    {
      platform = "open_meteo";
    }
    {
      platform = "met";
    }
  ];
}
