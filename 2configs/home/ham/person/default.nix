{config, ... }:
{
  services.home-assistant.config.person = [
    {
      name = "Felix";
      id = 1;
      device_trackers = [
        "device_tracker.felix_phone"
        "device_tracker.x"
      ];
    }
    {
      name = "Misa";
      id = 2;
      device_trackers = [
        "device_tracker.misa_phone"
      ];
    }
  ];
}
