{ lib, ...}:
let
  # https://www.radiotheque.de/stream/4744806739035994/ABC-Lounge-Music-Radio/pls/
  # http://listen.radionomy.com/ABC-Lounge
  # https://str1.openstream.co/589
  # https://listen.openstream.co/3139/audio
  # https://str1.openstream.co/589?aw_0_1st.collectionid%3D3139%26stationId%3D3139%26publisherId%3D613%26k%3D1659381767%26aw_0_azn.pcountry%3D%5B%22FR%22%2C%22IT%22%2C%22DE%22%2C%22ES%22%2C%22GB%22%2C%22CH%22%2C%22CA%22%2C%22AT%22%2C%22US%22%5D%26aw_0_azn.planguage%3D%5B%22en%22%2C%22fr%22%2C%22de%22%5D%26aw_0_azn.pgenre%3D%5B%22Jazz%22%2C%22Easy+Listening%22%2C%22Music%22%5D
  statecond = cond: { # cond must be a list
    condition = "template";
    value_template = "{{ trigger.to_state.state in ( " +
      (lib.concatMapStringsSep "," (x: "'${x}'") cond) + ") }}";
    };
  vol_change = 0.030;

  max_repeat = "30"; # max loops to repeat before bailing out
  remote = "sensor.arbeitszimmer_sound1_action";
  player = "media_player.office";
  last_state_sensor_name = "last_rotation_action_arbeitszimmer";
  last_state_sensor = "input_text.${last_state_sensor_name}";
  #      - service: media_player.volume_set
  #    target:
  #      entity_id: media_player.kitchen
  #    data:
  #      volume_level: {{ state_attr('media_player.kitchen', 'volume_level') + 0.02 }}
  rotate_stop = "brightness_stop";
  rotate_right = "brightness_move_up";
  rotate_left = "brightness_move_down" ;
  
  single_click = "toggle";
  double_click = "brightness_step_up";
  triple_click = "brightness_step_down";
in {
  services.home-assistant.config.input_text."${last_state_sensor_name}".name = "Last action of the arbeitszimmer";
  services.home-assistant.config.automation = [
    {
      trigger = {
        platform = "state";
        entity_id = remote;
        to = [ rotate_stop ];
      };
      action = [
          { service = "input_text.set_value";
            target.entity_id = last_state_sensor;
            data.value = "stop";
          }
      ];
    }
    {
      alias = "Perform Actions with ${remote}";
      trigger = {
        platform = "state";
        entity_id = remote;
        to = [ single_click double_click triple_click rotate_left rotate_right ];
      };
      #mode = "queued";
      #max = 5;
      mode = "single";
      #max_exceeded = "silent";
      action = [
        {
          choose = [
            {
              conditions = statecond [ single_click ];
              sequence = [
                { service = "media_player.media_play_pause";
                target.entity_id = player;
                }
              ];
            }
            {
              conditions = statecond [ rotate_left rotate_right ];
              sequence = let
                vol_up = toString vol_change;
                vol_down = toString (-1 * vol_change);
              in [
                {
                  variables.nextvol = ''{% if trigger.to_state.state in ( "${rotate_left}" ) -%} ${vol_down} {% else -%} ${vol_up} {% endif -%}'';
                  variables.state = ''{% if trigger.to_state.state in ( "${rotate_left}" ) -%} left {% else -%} right {% endif -%}'';
                }
                { service = "input_text.set_value";
                  target.entity_id = last_state_sensor;
                  data.value = ''{{ state }}'';
                }
                {
                  repeat = {
                    sequence = [
                      { service = "media_player.volume_set";
                        target.entity_id = player;
                        data.volume_level = ''{{ state_attr("${player}","volume_level")  + (nextvol|float) }}'';
                      }
                      { delay.milliseconds = "150"; }
                    ];
                    while = [
                      {
                          condition = "template";
                          value_template = ''{{ states("${last_state_sensor}") == state }}'';
                      }
                      {
                        condition = "template";
                        value_template = "{{ repeat.index <= ${max_repeat}}}";
                      }
                    ];
                  };
                }
              ];
            }
          ];
        }
      ];
    }
  ];
}
