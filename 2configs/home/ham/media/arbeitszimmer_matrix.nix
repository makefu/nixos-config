{ lib, ... }:
let
  remote = "sensor.schlafzimmer_music_remote_action";
  hlib = import ../lib;
  step = 0.02;
  #room = "bedroom";
  room = "office";

  player = "media_player.${room}";
  say = hlib.say."${room}";

  remote_action = key: actions: {
    conditions = ''{{ trigger.entity_id == 'binary_sensor.matrix_button_${toString key}' }}'';   
    sequence = actions;
  };
  all_buttons = map (key: "binary_sensor.matrix_button_${toString key}") [
    0 1 2 3 4 5 6 7 8 9
    "b9" "b10" "b11" "b12" "b13" "b14"
  ];
in
  {
    services.home-assistant.config.rest_command = {
      good_song = {
        url = "http://prism.r:8001/good";
        method = "POST";
      };
      bad_song = {
        url = "http://prism.r:8001/skip";
        method = "POST";
      };
    };
    services.home-assistant.config.automation =
    [
      { alias = "Arbeitszimmer Matrix music action";
        mode = "queued";
      trigger = [
          {
            platform = "state";
            entity_id = all_buttons;
            to = "on"; # ignore 'unavailable'
          }
      ];
      action =
        [
          { choose = [
            (remote_action "9" {
                service = "media_player.media_play";
                target.entity_id = player;
            })
            (remote_action "7" 
              {
                service = "media_player.media_mute";
                target.entity_id = player;
                data.is_volume_muted = ''{{ not state_attr('${player}' , 'is_volume_muted') }}'';
              }
            )
            (remote_action "2" 
              {
                service = "media_player.media_stop";
                target.entity_id = player;
              }
            )

            (remote_action "b9"  [ { service = "rest_command.good_song"; } ])
            (remote_action "b10" [ { service = "rest_command.bad_song";  } ])

            (remote_action "3" 
              ((say "Starte Lass") ++ [
              { service = "media_player.play_media";
                data = {
                  media_content_id = "http://radio.lassul.us:8000/radio.mp3";
                  media_content_type = "music";
                };
                target.entity_id = player;
              }
            ]))
            (remote_action "1"
              ((say "Starte Groovesalad") ++ [
              { service = "media_player.play_media";
                data = {
                  media_content_id = "http://ice2.somafm.com/groovesalad-128.mp3";
                  media_content_type = "music";
                };
                target.entity_id = player;
              }
            ]))
            (remote_action "8" {
                service = "media_player.volume_set";
                target.entity_id = player;
                data.volume_level = ''{{ state_attr("${player}","volume_level") + (${toString step}|float) }}'';   
            })
            (remote_action "5"{
                service = "media_player.volume_set";
                target.entity_id = player;
                data.volume_level = ''{{ state_attr("${player}","volume_level") - (${toString step}|float) }}'';   
            })
            ];
            #default = { };
          }
        ];
      }
    ];

}
