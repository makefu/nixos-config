{
  services.home-assistant.config.automation =
    [
      {
        trigger = [
          { platform = "time"; at = "03:21"; }
        ];
        action =
        [
          {
            service = "speedtestdotnet.speedtest";
          }
        ];
      }
  ];

}
