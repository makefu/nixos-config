let
  topic = "rfbridge";
  bridge = name: payload_on: payload_off:
  { platform = "mqtt";
    inherit name payload_on payload_off;
    command_topic = "/bam/${topic}/cmnd/rfcode";
    availability_topic = "/bam/${topic}/tele/LWT";
    payload_available= "Online";
    payload_not_available= "Offline";
  };
in
[
  (bridge "Nachtlicht A" "#414551" "#414554")
  (bridge "Nachtlicht B" "#415151" "#415154")
  (bridge "Nachtlicht C" "#415451" "#415454")
  (bridge "Nachtlicht D" "#41551F" "#415514")
]
