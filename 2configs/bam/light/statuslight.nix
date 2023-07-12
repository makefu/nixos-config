let
  tasmota_rgb = name: topic:
# LED WS2812b
#      effect_state_topic: "stat/led/Scheme"
#      effect_command_topic: "cmnd/led/Scheme"
#      effect_value_template: "{{ value_json.Scheme }}"
  { platform = "mqtt";
    inherit name;
    retain = false;
    qos = 1;
    #optimistic = true;
    # state
    command_topic = "/bam/${topic}/cmnd/POWER";
    state_topic = "/bam/${topic}/tele/STATE";
    value_template = "{{ value_json.POWER }}";
    availability_topic = "/bam/${topic}/tele/LWT";
    payload_on = "ON";
    payload_off = "OFF";
    payload_available= "Online";
    payload_not_available= "Offline";
    # brightness
    brightness_state_topic = "/bam/${topic}/tele/STATE";
    brightness_value_template = "{{value_json.Dimmer|default(100)}}";
    brightness_command_topic = "/bam/${topic}/cmnd/Dimmer";
    brightness_scale = 100;
    # color
    rgb_state_topic = "/bam/${topic}/stat/RESULT";
    rgb_command_topic = "/bam/${topic}/cmnd/Color2";
     rgb_value_template = "{{(value_json.Channel[0]*2.55)|int}},{{(value_json.Channel[1]*2.55)|int}},{{(value_json.Channel[2]*2.55)|int}}";

    # effects
    effect_state_topic = "/bam/${topic}/tele/STATE";
    effect_value_template = "{{value_json.Scheme|default(0)}}";
    effect_command_topic = "/bam/${topic}/cmnd/Scheme";
    effect_list = [
      0  # single color for LED light
      1  # start wake up sequence (same as Wakeup)
      2  # cycle up through colors using Speed option
      3  # cycle down through colors using Speed option
      4  # random cycle through colors using Speed and Fade
      5  # clock mode (example)
      6  # candlelight pattern
      7  # RGB pattern
      8  # Christmas pattern
      9  # Hannukah pattern
      10 # Kwanzaa pattern
      11 # rainbow pattern
      12 # fire pattern
    ];
  };
in {
  services.home-assistant.config.light =
  [
    (tasmota_rgb "Status Felix" "status1")
    (tasmota_rgb "Status Daniel" "status2")
    (tasmota_rgb "Buslicht" "buslicht")
  ];
}
