{


availability_topic: /ham/zigbee/bridge/state
command_topic: /ham/zigbee/flur_arbeitszimmer_osram2/set

  - platform: "mqtt"
    state_topic: "zigbee2mqtt/<FRIENDLY_NAME>"
    availability_topic: "zigbee2mqtt/bridge/state"
    payload_on: true
    payload_off: false
    value_template: "{{ value_json.battery_low}}"
    device_class: "battery"
}
