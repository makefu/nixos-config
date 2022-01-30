# Begin
let
in {
  services.home-assistant.config.automation =
    [
    ];
}

# example automation
    { alias = "";
      trigger = [
          {
            platform = "state";
            entity_id = "";
            to = "on";
            for.seconds = 0;
          }
      ];
      condition = [
        { condition = "state";
          entity_id = "";
          state = "off";
        }
      ];
      action =
        [
          { choose = [
            {
              conditions = {
                condition = "state";
                entity_id = "";
                state =  "on";
              };
              sequence = [{
                service = "home_assistant.turn_on";
                target.entity_id = "";
              }];
            }];
            default = { };
          }
        ];
      }
