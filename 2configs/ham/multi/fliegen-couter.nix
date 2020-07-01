# uses:
#  sensor.btn1_click
#  sensor.btn2_click
let
  hlib = import ../lib;
  fly_swat = for: btn: method: incr: {
    alias = "Increment ${method} for ${for}";
    trigger = {
      platform = "state";
      entity_id = "sensor.${btn}_click";
      to = method;
    };
    action = builtins.genList (cnt: {
      service = "counter.increment";
      data.entity_id = "counter.${for}_fliegen";
    }) incr;
  };
in {
  counter = {
    felix_fliegen = {};
    misa_fliegen = {};
  };
  automation = [
    (fly_swat "misa"  "btn1" "single" 1)
    (fly_swat "misa"  "btn1" "double" 2)
    (fly_swat "misa"  "btn1" "triple" 3)
    (fly_swat "felix"  "btn2" "single" 1)
    (fly_swat "felix"  "btn2" "double" 2)
    (fly_swat "felix"  "btn2" "triple" 3)
    {
      alias = "Send Fly Counter Update";
      trigger = [
        {
          platform = "state";
          entity_id = "counter.felix_fliegen";
        }
        {
          platform = "state";
          entity_id = "counter.misa_fliegen";
          #above = -1;
        }
      ];
      action = {
          service = "mqtt.publish";
          data_template = { # gauge-style
            payload = "{{ trigger.to_state.state }}";
            topic = "${hlib.prefix}/flycounter/{{ trigger.to_state.object_id }}";
          };
      };
    }
    {
      alias = "Reset Fly counters on midnight";
      trigger = {
        platform = "time";
        at = "01:00:00";
      };
      action = [
        { service = "counter.reset";
          data.entity_id = "counter.misa_fliegen";
        }
        { service = "counter.reset";
          data.entity_id = "counter.felix_fliegen";
        }
      ];
    }
  ];
}
