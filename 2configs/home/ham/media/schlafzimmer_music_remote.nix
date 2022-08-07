{ lib, ... }:
let
  remote = "sensor.schlafzimmer_music_remote_action";
  hlib = import ../lib;
  step = 0.03;
  room = "bedroom";
  #room = "office";

  player = "media_player.${room}";
  say = hlib.say."${room}";

  remote_action = state: actions: {
    conditions = ''{{ trigger.to_state.attributes.action == '${state}' }}'';   
    sequence = actions;
  };
  album_list =  [
# Wieso Weshalb Warum Junior
"Doris%20R%c3%bcbel,%20JUMBO%20Neue%20Medien%20%26%20Verlag%20GmbH/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Helfen,%20teilen,%20sich%20vertragen"
"Wieso%3f%20Weshalb%3f%20Warum%3f%20junior/Mein%20Kindergarten"
"Wieso%3f%20Weshalb%3f%20Warum%3f%20junior/Unser%20Werkzeug"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Am%20Meer"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Ampel,%20Stra%c3%9fe%20und%20Verkehr"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Autos%20und%20Laster"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Der%20Bagger"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Der%20Bauernhof"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Der%20Flughafen"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Der%20Pinguin"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Der%20Traktor"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Die%20Baustelle"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Die%20Eisenbahn"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Die%20Feuerwehr"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Die%20Jahreszeiten"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Die%20M%c3%bcllabfuhr"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Die%20Polizei"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Die%20Rettungsfahrzeuge"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Die%20Ritterburg"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Heute,%20morgen,%20jetzt%20und%20gleich"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Im%20Streichelzoo"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20In%20den%20Bergen"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Mama,%20Papa,%20Oma,%20Opa"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Mein%20Hund"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Tanken,%20waschen,%20reparieren"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Tiere%20in%20Afrika"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Unsere%20Tierkinder"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Unterwegs%20mit%20Bus%20und%20Bahn"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Was%20ich%20alles%20kann"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Was%20kriecht%20und%20krabbelt%20da%3f"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Was%20machen%20wir%20an%20Weihnachten%3f"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Was%20machen%20wir%20im%20Fr%c3%bchling%3f"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Was%20machen%20wir%20im%20Herbst%3f"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Was%20machen%20wir%20im%20Sommer%3f"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Was%20machen%20wir%20im%20Winter%3f"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Was%20macht%20der%20Fu%c3%9fballer%3f"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Was%20macht%20der%20Polizist"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Was%20macht%20die%20Prinzessin%3f"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Was%20w%c3%a4chst%20da%3f"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Wenn%20es%20dunkel%20wird"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Wer%20arbeitet%20auf%20der%20Baustelle%3f"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Wir%20feiern%20Geburtstag"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Wir%20gehen%20in%20den%20Zoo"
"Wieso%3f%20Weshalb%3f%20Warum%3f/Wieso%3f%20Weshalb%3f%20Warum%3f%20junior.%20Z%c3%a4hne%20putzen,%20Pipi%20machen"

  ];
  albums = lib.concatMapStringsSep ", " (x: ''"A:ALBUMARTIST/${x}"'') 
    album_list;
in
{
    services.home-assistant.config.automation =
    [
      { alias = "Schlafzimmer music action";
      trigger = [
          {
            platform = "state";
            entity_id = remote;
            attribute = "action";
            not_to = "";
          }
      ];
      action =
        [
          { choose = [
            (remote_action "on" { #also called by hold right and left
                service = "media_player.media_play";
                target.entity_id = player;
            })
            (remote_action "off" 
              {
                service = "media_player.volume_mute";
                target.entity_id = player;
                data.is_volume_muted = ''{{ not state_attr('${player}' , 'is_volume_muted') }}'';
              }
            )

            (remote_action "arrow_right_hold" 
              ((say "Starte Lassulus Super Radio") ++ [
              { service = "media_player.play_media";
                data = {
                  media_content_id = "http://radio.lassul.us:8000/radio.mp3";
                  media_content_type = "music";
                };
                target.entity_id = player;
              }
            ]))
            (remote_action "arrow_left_hold"
              ((say "Starte Deep House Music") ++ [
              { service = "media_player.play_media";
                data = {
                  media_content_id = "http://live.dancemusic.ro:7000/stream.mp3";
                  media_content_type = "music";
                };
                target.entity_id = player;
              }
            ]))
            #(remote_action "arrow_left_release" {

            #})
            #(remote_action "arrow_left_release" {

            #})
            # TODO: choose random kindermusik?
            (remote_action "brightness_move_up" 
              ((say "Starte Liam Album") ++ [
                {
                  service = "media_player.play_media";
                  target.entity_id = player;
                  data = {
                    media_content_id = "{{ [${albums}]|random }}";
                    media_content_type = "album";
                  };
                }
              ])
            )
            (remote_action "brightness_move_down" 
              ((say "Stoppe Musik") ++ [
                {
                  service = "media_player.media_stop";
                  target.entity_id = player;
                }
              ])
            )
            (remote_action "arrow_right_click" {

                service = "media_player.volume_set";
                target.entity_id = player;
                data.volume_level = ''{{ state_attr("${player}","volume_level") + (${toString step}|float) }}'';   
            })
            #(remote_action "brightness_move_down" {
            (remote_action "arrow_left_click"{
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