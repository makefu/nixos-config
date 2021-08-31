let
  relay = "switch.terrasse_plug_relay";
  timeout = "300";
in {
  services.home-assistant.config.automation = [
      { alias = "Always turn off Charging station after ${toString (timeout)}m";
        trigger = [
          {
            platform = "state";
            entity_id = relay;
            to = "on";
            for.minutes = timeout;
          }
        ];
        action =
        [
          {
            service = "homeassistant.turn_off";
            entity_id =  [ relay ];
          }
        ];
      }
  ];
}
