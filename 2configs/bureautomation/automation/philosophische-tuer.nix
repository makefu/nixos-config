{ config, pkgs, lib, ... }:

let
  short_threshold = 30; #seconds
  long_threshold = 30; #minutes
  sensor = "binary_sensor.buerotuer_contact";

  # get the list of all
  name = "tueraudio";
  prefix = "http://localhost:8123/local/${name}";
  audiodir = "${config.services.home-assistant.configDir}/www/${name}";
  recordrepo = pkgs.fetchFromGitHub {
    owner = "makefu";
    repo = "philosophische_tuer";
    rev = "607eff7";
    sha256 = "1qlyqmc65yfb42q4fzd92vinx4i191w431skmcp7xjncb45lfp8j";
  };
  samples = user: lib.mapAttrsToList
    (file: _: ''"${prefix}/${user}/${file}"'')
    (builtins.readDir (toString ( recordrepo+ "/recordings/${user}")));
    random_tuerspruch = ''{{['' + (lib.concatStringsSep "," (
      (samples "Felix") ++ (samples "Sofia") ++ (samples "Markus")
      )) + ''] | random}}''; # TODO read from derivation
in
{
  systemd.services.copy-philosophische-tuersounds = {
    description = "copy philosophische tuer";
    wantedBy = [ "multi-user.target"  ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeDash "update-samples" ''
        rm -rf "${audiodir}"
        cp -vr "${recordrepo}/recordings" "${audiodir}"
      '';
    };
  };
  services.home-assistant.config = {
    media_extractor = { };
    script."philosophische_tuer" = {
      alias = "Durchsage der philosophischen Tür";
      sequence = [
        { service = "media_player.play_media";
          data = {
            entity_id = "media_player.mpd";
            media_content_type = "playlist";
            media_content_id = "ansage";
          };
        }
        { delay.seconds = 5; }
        { service = "media_extractor.play_media";
          entity_id =  "media_player.mpd";
          data_template = {
            media_content_id = random_tuerspruch;
            media_content_type = "MUSIC";
          };
        }
      ];
    };
    automation =
    [
      {
        alias = "Tür offen seit ${toString short_threshold} sekunden";
        trigger =
        { platform = "state";
          entity_id = sensor;
          to = "on";
          for.seconds = 60;
        };
        action = [
          { service = "homeassistant.turn_on";
            entity_id = "script.philosophische_tuer";
          }
        ];
      }
      {
        alias = "Tür offen seit ${toString long_threshold} minuten";
        trigger =
        { platform = "state";
          entity_id = sensor;
          to = "on";
          for.minutes = long_threshold;
        };

        action = [
          { service = "homeassistant.turn_on";
            entity_id = "script.philosophische_tuer" ;
          }
          { service = "tts.google_say";
            entity_id =  "media_player.mpd";
            data_template = {
              message = "BEEP BOOP - Die Tür ist schon seit ${toString long_threshold} Minuten offen! Student Nummer {{ range(1,500) | random }}, bitte schliesse die Tür";
              language = "de";
            };
          }
        ];
      }
    ];
  };

}
