let
  tasmota_pwm = name: topic: pwmid: max:
    let
      id = "PWM${toString pwmid}";
    in { platform = "mqtt";
    inherit name;
    state_topic = "/bam/${topic}/stat/RESULT";
    state_value_template = ''{%- if value_json["PWM"]["${id}"]| int > 0 -%} ${toString max} {%- else -%} 0 {%- endif -%}'';

    command_topic = "/bam/${topic}/cmnd/${id}";
    on_command_type = "brightness";
    brightness_command_topic = "/bam/${topic}/cmnd/${id}";
    brightness_value_template = ''{{value_json["PWM"]["${id}"]}}'';
    brightness_scale = max;
    payload_on = "${toString max}";
    payload_off = "0";
    availability_topic = "/bam/${topic}/tele/LWT";
    payload_available= "Online";
    payload_not_available= "Offline";
    retain = true;
    optimistic = false;
    qos = 0;
  };
in {
  services.home-assistant.config.light =
  [
  # (tasmota_pwm "RedButton LED" "redbutton" 1 1023) #LED PWM1
  #  (tasmota_pwm "RedButton Buzzer" "redbutton" 2 512) #buzzer PWM2
  ];
}
