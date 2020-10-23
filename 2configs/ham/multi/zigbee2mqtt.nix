# provides:
#   switch
#   automation
#   binary_sensor
#   sensor
#   input_select
#   timer
let
  inherit (import ../lib) zigbee;
  prefix = zigbee.prefix;
in {
  sensor =

     [
    # Sensor for monitoring the bridge state
    {
      platform = "mqtt";
      name = "Zigbee2mqtt Bridge state";
      state_topic = "${prefix}/bridge/state";
      icon = "mdi:router-wireless";
    }
    # Sensor for Showing the Zigbee2mqtt Version
    {
      platform = "mqtt";
      name = "Zigbee2mqtt Version";
      state_topic = "${prefix}/bridge/config";
      value_template = "{{ value_json.version }}";
      icon = "mdi:zigbee";
    }
    # Sensor for Showing the Coordinator Version
    {
      platform = "mqtt";
      name = "Coordinator Version";
      state_topic = "${prefix}/bridge/config";
      value_template = "{{ value_json.coordinator }}";
      icon = "mdi:chip";
    }
  ];
  switch = [
  {
    platform = "mqtt";
    name = "Zigbee2mqtt Main join";
    state_topic = "${prefix}/bridge/config/permit_join";
    command_topic = "${prefix}/bridge/config/permit_join";
    payload_on = "true";
    payload_off = "false";
  }
  ];
  automation = [
    {
      alias = "Zigbee2mqtt Log Level";
      initial_state = "on";
      trigger = {
        platform = "state";
        entity_id = "input_select.zigbee2mqtt_log_level";
      };
      action = [
        {
          service =  "mqtt.publish";
          data = {
            payload_template = "{{ states('input_select.zigbee2mqtt_log_level') }}";
            topic =  "${prefix}/bridge/config/log_level";
          };
        }
      ];
    }
# Automation to start timer when enable join is turned on
    {
      id = "zigbee_join_enabled";
      alias = "Zigbee Join Enabled";
      trigger =
      {
        platform = "state";
        entity_id = "switch.zigbee2mqtt_main_join";
        to = "on";
      };
      action =
      {
        service = "timer.start";
        entity_id = "timer.zigbee_permit_join";
      };
    }
#  # Automation to stop timer when switch turned off and turn off switch when timer finished
    {
      id = "zigbee_join_disabled";
      alias = "Zigbee Join Disabled";
      trigger = [
        {
          platform = "event";
          event_type = "timer.finished";
          event_data.entity_id = "timer.zigbee_permit_join";
        }
        {
          platform = "state";
          entity_id = "switch.zigbee2mqtt_main_join";
          to = "off";
        }
      ];
      action = [
        { service = "timer.cancel";
          data.entity_id = "timer.zigbee_permit_join";
        }
        { service = "switch.turn_off";
          entity_id = "switch.zigbee2mqtt_main_join";
        }
      ];
    }
  ];
  input_select.zigbee2mqtt_log_level =
  {
    name = "Zigbee2mqtt Log Level";
    options = [
      "debug"
      "info"
      "warn"
      "error"
    ];
    initial = "info";
    icon = "mdi:format-list-bulleted";
  };

  timer.zigbee_permit_join =
  {
    name = "Zigbee Time remaining";
    duration = 120;
  };
}
