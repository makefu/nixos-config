{
  services.home-assistant.config.automation =
  [
    { alias = "State on HA start-up";
    trigger = {
        platform = "homeassistant";
        event = "start";
      };
      action = [
        # Startup State
        { service = "mqtt.publish";
          data = {
            topic = "/bam/sonoffs/cmnd/state";
            payload = "";
          };
        }
        # Firmware Version
        { service = "mqtt.publish";
          data = {
            topic = "/bam/sonoffs/cmnd/status";
            payload = "2";
          };
        }
        # Will trigger restart of all devices!
        #{ service = "mqtt.publish";
        #  data = {
        #    topic = "sonoffs/cmnd/SetOption59"; # configure sending state on power change
        #    payload = "1";
        #  };
        #}
      ];
    }
  ];
}
