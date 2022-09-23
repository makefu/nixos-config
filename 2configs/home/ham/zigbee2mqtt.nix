# provides:
#   switch
#   automation
#   binary_sensor
#   sensor
#   input_select
#   timer
let
  inherit (import ./lib) zigbee;
  prefix = zigbee.prefix;
in
{
  services.home-assistant.config = {
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

  };
}
