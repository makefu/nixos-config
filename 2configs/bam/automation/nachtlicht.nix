{
  services.home-assistant.config.automation =
  [
    # TODO: trigger if it is before dusk and somebody arives but nachtlichter are
    # off from last day
    # TODO: do not have nachtlicht turned on at night
    {
      alias = "Turn on Nachtlicht at dusk"; # when it gets dim
      trigger =
      { platform = "numeric_state";
        entity_id = "sun.sun";
        value_template = "{{ state.attributes.elevation }}";
        below = 10;

      };
      action =
      { service = "homeassistant.turn_on";
        entity_id =  [ "group.nachtlicht" ];
      };
    }
    {
      alias = "Turn off Nachtlicht at dawn";
      trigger =
      { platform = "sun";
        event = "sunrise";
        offset = "01:30:00"; # on dawn
      };
      # TODO: when somebody is still in the buero
      # condition = 
      #{
      #};
      action =
      { service = "homeassistant.turn_off";
        entity_id =  [ "group.nachtlicht" ];
      };
    }
  ];
}
