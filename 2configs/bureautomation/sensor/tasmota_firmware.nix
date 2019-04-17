let
  tasmota_firmware = topic:
  { platform = "mqtt";
  name = "${topic} Firmware";
  state_topic = "/bam/${topic}/stat/STATUS2";
  availability_topic = "/bam/${topic}/tele/LWT";
  value_template = "v{{value_json.StatusFWR.Version}}";
  payload_available= "Online";
  payload_not_available= "Offline";
  };
in
  map tasmota_firmware [
    "plug" "plug2" "plug3" "plug4" "plug5"
    "status1" "status2" "buslicht"
    "rfbridge"
  ]
