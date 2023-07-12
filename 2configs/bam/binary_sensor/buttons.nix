let
  tasmota_button = name: topic:
  # detects a pushbutton press from tasmota
  { platform = "mqtt";
    inherit name;
    state_topic = "/bam/${topic}/cmnd/POWER";
    availability_topic = "/bam/${topic}/tele/LWT";
    payload_on = "ON";
    payload_off = "OFF";
    payload_available= "Online";
    payload_not_available= "Offline";
    # expire_after = "5"; #expire after 5 seconds
    qos = 1;
  };
in {
  services.home-assistant.config.binary_sensor =
    [
    (tasmota_button "RedButton" "redbutton")
  ];
}
