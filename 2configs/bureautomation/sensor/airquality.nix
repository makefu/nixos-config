[
  # coming from 2configs/stats/telegraf/
  { platform = "mqtt";
    name = "Air Quality";
    state_topic = "/telegraf/wbob/airquality";
    value_template = "{{ value_json.fields.value }}";
    unit_of_measurement = "VOC";
  }
]
