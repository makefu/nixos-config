let
  tasmota_plug = name: topic:
  { platform = "mqtt";
    inherit name;
    state_topic = "/bam/${topic}/stat/POWER";
    command_topic = "/bam/${topic}/cmnd/POWER";
    availability_topic = "/bam/${topic}/tele/LWT";
    payload_on= "ON";
    payload_off= "OFF";
    payload_available= "Online";
    payload_not_available= "Offline";
  };
in [
  (tasmota_plug "Bauarbeiterlampe" "plug")
  (tasmota_plug "Blitzdings" "plug2")
  (tasmota_plug "Fernseher" "plug3")
  (tasmota_plug "Feuer" "plug4")
  (tasmota_plug "Blaulicht" "plug5")
]
