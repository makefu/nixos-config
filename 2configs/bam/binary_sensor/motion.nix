{
  services.home-assistant.config.binary_sensor =
  [
    { platform = "mqtt";
      device_class = "motion";
      name = "Motion";
      state_topic = "/bam/easy2/movement/Switch";
      payload_on = "1";
      payload_off = "0";
      availability_topic = "/bam/easy2/tele/LWT";
      payload_available = "Online";
      payload_not_available = "Offline";
    }
  ];
}
