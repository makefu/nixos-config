{
  services.home-assistant.config.sensor =
    [
      { platform = "dwd_weather_warnings";
        region_name = "Stadt Stuttgart";
      }
      { platform = "nina";
      }
  ];
}
