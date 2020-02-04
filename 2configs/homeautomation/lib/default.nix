let
  prefix = "/ham";
in
{
  inherit prefix;
  say = let
    # returns a list of actions to be performed on an mpd to say something
    tts = { message, entity }:
    [
      {
        service = "media_player.turn_on";
        data.entity_id = entity;
      }
      {
        service = "media_player.play_media";
        data = {
          entity_id = entity;
          media_content_type = "playlist";
          media_content_id = "ansage";
        };
      }
      {
        service = "media_player.turn_on";
        data.entity_id = entity;
      }
      { delay.seconds = 8; }
      {
        service = "tts.say";
        entity_id =  entity;
        data_template = {
          inherit message;
          language = "de";
        };
      }
    ];
  in
  {
    firetv = message: tts {
      inherit message;
      entity = "firetv";
    };
  };
  zigbee = let
    prefix = "/ham/zigbee";
  in
  {
    inherit prefix;
    state = name: {
      platform = "mqtt";
      name = "zigbee ${name} connectivity";
      state_topic = "${prefix}/${name}";
      availability_topic = "${prefix}/bridge/state";
      payload_on = true;
      payload_off = false;
      value_template = "{{ value_json.state }}";
      device_class = "connectivity";
    };
      battery = name: {
        platform = "mqtt";
        name = "zigbee ${name} battery";
        state_topic = "${prefix}/${name}";
        availability_topic = "${prefix}/bridge/state";
        unit_of_measurement = "%";
        device_class = "battery";
        value_template = "{{ value_json.battery }}";
      };
      linkquality = name: {
        platform = "mqtt";
        name = "zigbee ${name} linkquality";
        state_topic = "${prefix}/${name}";
        availability_topic = "${prefix}/bridge/state";
        unit_of_measurement = "-";
        value_template = "{{ value_json.linkquality }}";
      };
      temperature = name: {
        platform = "mqtt";
        name = "zigbee ${name} temperature";
        state_topic = "${prefix}/${name}";
        availability_topic = "${prefix}/bridge/state";
        unit_of_measurement = "°C";
        device_class = "temperature";
        value_template = "{{ value_json.temperature }}";
      };
      humidity = name: {
        platform = "mqtt";
        name = "zigbee ${name} humidity";
        state_topic = "${prefix}/${name}";
        availability_topic = "${prefix}/bridge/state";
        unit_of_measurement = "%";
        device_class = "humidity";
        value_template = "{{ value_json.humidity }}";
      };
      pressure = name: {
        platform = "mqtt";
        state_topic = "${prefix}/${name}";
        name = "zigbee ${name} pressure";
        availability_topic = "${prefix}/bridge/state";
        unit_of_measurement = "hPa";
        device_class = "pressure";
        value_template = "{{ value_json.pressure }}" ;
      };
      click = name:
      {
        platform = "mqtt";
        name = "zigbee ${name} click";
        state_topic = "${prefix}/${name}";
        availability_topic = "${prefix}/bridge/state";
        icon = "mdi:toggle-switch";
        value_template = "{{ value_json.click }}";
      };
      contact = name: {
        platform = "mqtt";
        name = "zigbee ${name} contact";
        state_topic = "${prefix}/${name}";
        availability_topic = "${prefix}/bridge/state";
        payload_on = false;
        payload_off = true;
        value_template = "{{ value_json.contact }}";
        device_class = "door";
      };
  };
  esphome =
  {
    temp = {host, topic ? "temperature" }:
    {
      platform = "mqtt";
      name = "${host} Temperature";
      device_class = "temperature";
      unit_of_measurement =  "°C";
      icon = "mdi:thermometer";
      state_topic = "${prefix}/${host}/sensor/${topic}/state";
      availability_topic = "${prefix}/${host}/status";
      payload_available = "online";
      payload_not_available = "offline";
    };
    hum = {host, topic ? "humidity" }:
    {
      platform = "mqtt";
      unit_of_measurement = "%";
      icon = "mdi:water-percent";
      device_class = "humidity";
      name = "${host} Humidity";
      state_topic = "${prefix}/${host}/sensor/${topic}/state";
      availability_topic = "${prefix}/${host}/status";
      payload_available = "online";
      payload_not_available = "offline";
    };
    # copied from "homeassistant/light/fablab_led/led_ring/config"
    led = {host,  topic ? "led", name ? host}:
    { # name: fablab_led
      # topic: led_ring
      platform = "mqtt";
      inherit name;
      schema = "json";
      brightness =  true;
      rgb =  true;
      effect =  true;
      effect_list = [ # TODO: may be different
        "Random"
        "Strobe"
        "Rainbow"
        "Color Wipe"
        "Scan"
        "Twinkle"
        "Fireworks"
        "Addressable Flicker"
        "None"
      ];
      state_topic = "${prefix}/${host}/light/${topic}/state";
      command_topic = "${prefix}/${host}/light/${topic}/command";
      availability_topic = "${prefix}/${host}/status";
      payload_available = "online";
      payload_not_available = "offline";
      qos = 1;
    };
    # Feinstaub
    dust_25m = { host, name ? "${host} < 2.5µm", topic ? "particulate_matter_25m_concentration" }:
    {
      platform = "mqtt";
      unit_of_measurement = "µg/m³";
      icon = "mdi:chemical-weapon";
      inherit name;
      state_topic = "${prefix}/${host}/sensor/${topic}/state";
      availability_topic = "${prefix}/${host}/status";
    };
    dust_100m = {host, name ? "${host} < 10µm", topic ? "particulate_matter_100m_concentration" }:
    {
      platform = "mqtt";
      unit_of_measurement = "µg/m³";
      icon = "mdi:chemical-weapon";
      inherit name;
      state_topic = "${prefix}/${host}/sensor/${topic}/state";
      availability_topic = "${prefix}/${host}/status";
    };
    ip = {host, name ? "${host} IP", topic ? "ip_address" }:
    {
      platform = "mqtt";
      inherit name;
      state_topic = "${prefix}/${host}/sensor/${topic}/state";
      availability_topic = "${prefix}/${host}/status";
    };
    wifi = {host, name ? "${host} Wifi Signal", topic ? "wifi_signal" }:
    {
      platform = "mqtt";
      unit_of_measurement = "dB";
      icon = "mdi:wifi";
      inherit name;
      state_topic = "${prefix}/${host}/sensor/${topic}/state";
      availability_topic = "${prefix}/${host}/status";
    };
    switch = {host, name ? "${host} Button", topic ? "btn" }:
    # host: ampel
    # name: Button 1
    # topic: btn1
    {
      inherit name;
      platform = "mqtt";
      state_topic = "${prefix}/${host}/sensor/${topic}/state";
      command_topic = "${prefix}/${host}/switch/${topic}/state";
      availability_topic = "${prefix}/${host}/status";
    };
  };
  tasmota =
  {
    plug = {host, name ? host, topic ? host}:
    {
      platform = "mqtt";
      inherit name;
      state_topic = "sonoff/stat/${topic}/POWER1";
      command_topic = "sonoff/cmnd/${topic}/POWER1";
      availability_topic = "sonoff/tele/${topic}/LWT";
      payload_on= "ON";
      payload_off= "OFF";
      payload_available= "Online";
      payload_not_available= "Offline";
      retain = false;
      qos = 1;
    };
    am2301 = { name, host, topic?host }:
    [ { platform = "mqtt";
        name = "${name} Temperatur";
        state_topic = "${prefix}/${topic}/tele/SENSOR";
        value_template = "{{ value_json.AM2301.Temperature }}";
        unit_of_measurement = "°C";
      }
      { platform = "mqtt";
        name = "${name} Luftfeuchtigkeit";
        state_topic = "${prefix}/${topic}/tele/SENSOR";
        value_template = "{{ value_json.AM2301.Humidity }}";
        unit_of_measurement = "%";
      }
    ];
    bme = { name, host, topic?host }:
    [ { platform = "mqtt";
        name = "${name} Temperatur";
        state_topic = "${prefix}/${topic}/tele/SENSOR";
        value_template = "{{ value_json.BME280.Temperature }}";
        unit_of_measurement = "°C";
      }
      { platform = "mqtt";
        name = "${name} Luftfeuchtigkeit";
        state_topic = "${prefix}/${topic}/tele/SENSOR";
        value_template = "{{ value_json.BME280.Humidity }}";
        unit_of_measurement = "%";
      }
      { platform = "mqtt";
        name = "${name} Luftdruck";
        state_topic = "${prefix}/${topic}/tele/SENSOR";
        value_template = "{{ value_json.BME280.Pressure }}";
        unit_of_measurement = "hPa";
      }
    ];
    rgb = { name, host, topic?host }:
  { platform = "mqtt";
    inherit name;
    retain = false;
    qos = 1;
    optimistic = false;
    # state
    # TODO: currently broken, will not use the custom state topic
    #state_topic = "${prefix}/${topic}/stat/POWER";
    state_topic = "${prefix}/${topic}/stat/POWER";
    command_topic = "${prefix}/${topic}/cmnd/POWER";
    availability_topic = "${prefix}/${topic}/tele/LWT";
    payload_on= "ON";
    payload_off= "OFF";
    payload_available= "Online";
    payload_not_available= "Offline";
    # brightness
    brightness_state_topic = "${prefix}/${topic}/stat/Dimmer";
    brightness_command_topic = "${prefix}/${topic}/cmnd/Dimmer";
    brightness_value_template = "{{ value_json.Dimmer }}";
    brightness_scale = 100;
    # color
    rgb_state_topic = "${prefix}/${topic}/stat/Color";
    rgb_command_topic = "${prefix}/${topic}/cmnd/MEM1"; # use enabled  rule
    rgb_command_mode = "hex";
    rgb_command_template = "{{ '%02x%02x%02x' | format(red, green, blue)}}";
    # effects
    effect_state_topic = "${prefix}/${topic}/stat/Scheme";
    effect_command_topic = "${prefix}/${topic}/cmnd/Scheme";
    effect_value_template = "{{ value_json.Scheme }}";
    effect_list = [ 0 1 2 3 4 5 6 7 8 9 10 11 12 ];
};
    motion = { name, host, topic?host }:
    { platform = "mqtt";
      device_class = "motion";
      inherit name;
      # TODO: currently broken, will not use the custom state topic
      state_topic = "${prefix}/${topic}/stat/POWER";
      payload_on = "ON";
      payload_off = "OFF";
      availability_topic = "${prefix}/${topic}/tele/LWT";
      payload_available = "Online";
      payload_not_available = "Offline";
    };
  };
}
