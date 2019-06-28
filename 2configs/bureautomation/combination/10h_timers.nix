{lib, ... }:
let
  persons = [ "frank"  "daniel" "thorsten" "carsten" "thierry" "ecki" 
  # "felix" # custom actions
  ];
  random_zu_lange = name: ''{{ [
    "Du musst jetzt endlich nach Hause gehen ${name}!",
    "10 Stunden sind rum, bald schenkst du den Franzosen deine Lebenszeit",
    "Nur eine Minute über 10 Stunden kann zu einer Stunde Arbeit für Thorsten werden, ${name}.",
    "In 10 Minuten kommt dich der Security Mann holen, ${name}",
      "Zu lange, ${name}!" ] | random }}'' ;


  random_announce = name: ''{{ [
    "Guten Tag ${name}!",
    "${name} is in da House",
    "Ahoi ${name}",
    "Moinsen ${name}",
    "Moin Moin ${name}",
    "Palim, Palim ${name}",
    "Vorwärts Genosse ${name}",
    "Gemeinsame Grüße, Genosse ${name}",
    "Sozialistische Grüße, Genosse ${name}",
    "Konzentrierte Grüße, Genosse ${name}",
    "Ach, der ${name} ist auch wieder da...",
    "Nicht ${name} schon wieder",
    "Tri tra tralala, der ${name} ist wieder da.",
    "Na sieh mal einer an, ${name} hat es auch her geschafft",
    "Wer ist im Büro eingetroffen? ${name} ist es!",
    "Willkommen in deinem Lieblingsbüro, ${name}.",
    "Klopf, Klopf, wer ist da? ${name} ist da!",
    "Messer, Gabel, Schere, Licht sind für kleinen ${name} nicht.",
    "Ich kenne ein Geheimnis, ${name} ist abgekommen",
    "Wir sind ${name}. Sie werden assimiliert werden",
    "Achtung, es erfolgt eine Durchsage. ${name} ist eingetroffen",
    "Die Scanner haben eine dem System bekannte Lebensform mit dem Namen ${name} detektiert",
    "Das Büro sieht dich, ${name}",
    "Im Kalender von ${name} sind heute acht Meetings eingeplant, von denen zwei bereits verpasst wurden",
    "Das Postfach von ${name} beinhaltet einhundertachtundzwanzig ungelesene E-Mails.",
    "Nachricht von Serge: ${name}, bitte melden Sie sich Umgehend bei mir im Büro!",
    "Luftqualität hat sich durch das Eintreffen von ${name} um zweihunder Punkte verschlechtert, bitte alle Fenster öffnen.",
    "${name} arbeitet gern für seinen Konzern",
    "${name} ist nur froh im Großraumbüro",
    "Für ${name} ist die schönste Zeit ... die Arbeit",
    "Ein Fleißbienchen für ${name} zum rechtzeitigen Erscheinen im Büro",
    "${name} ist heute wohl doch nicht im Office Home",
    "${name} ist bereit für einen Tag voller Meetings",
    "Trotz schwerer Männergrippe ist ${name} heute im Büro erschienen.",
    "${name} kenne keine Parteien mehr, ${name} kenne nur noch Arbeitsplätze",
    "${name}, Frage nicht, was dein Arbeitsplatz für dich tun kann. Frage, was du für deinen Arbeitsplatz tun kannst",
    "${name} läuft bis in den Jemen - für sein Unternehmen. ${name} schwimmt bis nach Birma - für meine Firma",
    "Der Cyberian ${name} ist gekommen um die Bahnwelt vor Cyber-Angriffen zu schützen",
    "Alles paletto im Ghetto, ${name}?",
    "Hach, ${name}, wenn du hier rein kommst fühlt es sich gleich wieder an wie Montag.",
    "Oh nein, nicht schon wieder ${name}",
    "Wer wohnt in der Ananas ganz tief im Meer? ${name} Schwammkopf!",
    "Arbeit ist Freizeit! Wachstum ist Fortschritt! Sicherheit ist Freiheit!",
    "Willkommen ${name}"] | random }}'' ;
  patterns = [
    [1000 500 250] # TODO: maybe even play a short audio announcement?
    [150 150 150]
    [255 255]
    [500 500 100]
    [100 1000 100]
    # [125 250 500]
  ];
  tmr_10h = name: {
    "${name}_10h" = {
      name = "${name} 10h Timer";
      duration = "10:00:00";
    };
  };
  multi_flash = { entity, delays ? [ 500 ], alias ?  "${entity}_multi_flash_${toString (lib.length delays)}" }:
  {
    inherit alias;
    sequence = lib.flatten (builtins.map (delay: [
      { service = "homeassistant.turn_on";
        data.entity_id = entity;
      }
      { delay.milliseconds = delay; }
      { service = "homeassistant.turn_off";
        data.entity_id = entity;
      }
      { delay.milliseconds = delay; }
    ]
     ) delays);
   };

  buzz_user = name: delays: { "buzz_${name}" = (multi_flash {
      entity = "light.redbutton_buzzer";
      inherit delays;
      alias = "Red Button Buzz ${name}";
    });
  };

  zu_lange_user = name:
  { "announce_${name}" = {
      alias = "Random Zu Lange ${name}";
      sequence = [
        { service = "media_player.play_media";
          data = {
            entity_id = "media_player.mpd";
            media_content_type = "playlist";
            media_content_id = "ansage";
          };
        }
        { delay.seconds = 5; }
        { service = "tts.google_say";
          entity_id =  "media_player.mpd";
          data_template = {
            message = random_zu_lange name;
            language = "de";
          };
        }
      ];
    };
  };
  announce_user = name:
  { "announce_${name}" = {
      alias = "Random Announce ${name}";
      sequence = [
        { delay.seconds = 10; }
        { service = "media_player.play_media";
          data = {
            entity_id = "media_player.mpd";
            media_content_type = "playlist";
            media_content_id = "ansage";
          };
        }
        { delay.seconds = 5; }
        { service = "tts.google_say";
          entity_id =  "media_player.mpd";
          data_template = {
            message = random_announce name;
            language = "de";
          };
        }
      ];
    };
  };
  automation_10h = name: [
    { alias = "start ${name} 10h";
      trigger = {
        platform = "state";
        # TODO: ecki
        entity_id = [ "device_tracker.${name}_phone"];
        from =  "not_home";
        to = "home";
      };
      condition = {
        condition = "and";
        conditions = [
          {
            condition = "state";
            entity_id = "timer.${name}_10h";
            state =  "idle";
          }
          {
            condition = "time";
            after   = "06:00:00";
            before  = "12:00:00";
          }
        ];
      };
      action = [
        { service = "timer.start";
          entity_id =  [ "timer.${name}_10h" ] ;
        }
        { service = "homeassistant.turn_on";
          entity_id =  [
            # "script.buzz_${name}"
            "script.blitz_10s"
            "script.announce_${name}"
          ];
        }
      ];
    }

    {
      alias = "Zu lange ${name}!";
      trigger =
      {
        platform = "event";
        event_type = "timer.finished";
        event_data.entity_id = "timer.${name}_10h";
      };
      action =
      [
        { service = "homeassistant.turn_on";
          entity_id =  [
            "script.blitz_10s"
            "script.zu_lange_${name}"
          ];
        }
      ];
    }
  ];
in
{
  timer =lib.fold lib.recursiveUpdate {}
    ([
      (tmr_10h "felix") 
    { felix_8_30h = {
        name = "Felix 8_30h Timer";
        duration = "08:30:00";
      };
      felix_7h = {
        name = "Felix 7h Timer";
        duration = "07:00:00";
      };
    }
    ] ++  (map tmr_10h persons));
  automation = lib.flatten (map automation_10h persons) ++
  [
  { alias = "start Felix 10h";
    trigger = {
      platform = "state";
      entity_id = [ "device_tracker.felix_phone" "device_tracker.felix_laptop" ];
      from =  "not_home";
      to = "home";
    };
    condition = {
      condition = "and";
      conditions = [
        {
          condition = "state";
          entity_id = "timer.felix_10h";
          state =  "idle";
        }
        {
          condition = "time";
          after   = "06:00:00";
          before  = "12:00:00";
        }
      ];
    };
    action = [
      { service = "timer.start";
        entity_id =  [ "timer.felix_10h" "timer.felix_8_30h" "timer.felix_7h" ] ;
      }
      { service = "homeassistant.turn_on";
        entity_id =  [
          # "script.buzz_felix"
          "script.blitz_10s"
        ];
      }
      {
        service = "tts.google_say";
        entity_id =  "media_player.mpd";
        data_template = {
          message = "Willkommen, Felix!";
          language = "de";
        };
      }
      { service = "light.turn_on";
      data = {
          effect = "2";
          entity_id =  [ "light.status_felix" ];
        };
      }
    ];
  }

  { alias = "Disable Felix timer at button press";
    trigger = {
      platform = "state";
      entity_id = "binary_sensor.redbutton";
      to = "on";
    };
    condition = {
      condition = "and";
      conditions = [
        {
          condition = "state";
          entity_id = "timer.felix_10h";
          state =  "active";
        }
        {
          condition = "time";
          after = "12:00:00";
          before  = "22:00:00";
        }
      ];
    };
    action =
    [
      {
        service = "timer.cancel";
        entity_id =  [ "timer.felix_10h" "timer.felix_8_30h" "timer.felix_7h" ];
      }
      {
        service = "homeassistant.turn_on";
        entity_id =  [ "script.buzz_red_led_fast"  ];
      }
      {
        service = "homeassistant.turn_off";
        entity_id =  [ "light.status_felix"  ];
      }
    ];
  }

  {
    alias = "Genug gearbeitet Felix";
    trigger =
    {
      platform = "event";
      event_type = "timer.finished";
      event_data.entity_id = "timer.felix_7h";
    };
    action =
    [
      { service = "light.turn_on";
        data = {
          rgb_color= [0 255 0];
          # effect = "0";
          entity_id =  [ "light.status_felix" ];
        };
      }
    ];
  }

  {
    alias = "nun aber nach hause";
    trigger =
    {
      platform = "event";
      event_type = "timer.finished";
      event_data.entity_id = "timer.felix_8_30h";
    };
    action =
    [
      { service = "light.turn_on";
        data = {
          rgb_color= [255 255 0];
          # effect = "0";
          entity_id =  [ "light.status_felix" ];
        };
      }
    ];
  }

  {
    alias = "Zu lange Felix!";
    trigger =
    {
      platform = "event";
      event_type = "timer.finished";
      event_data.entity_id = "timer.felix_10h";
    };
    action =
    [
      {
        service = "notify.telegrambot";
        data = {
          title = "Zu lange Felix!";
          message = "Du bist schon 10 Stunden auf Arbeit, geh jetzt gefälligst nach Hause!";
        };
      }
      {
        service = "homeassistant.turn_on";
        entity_id =  [
          # "script.buzz_felix"
          "script.blitz_10s"
        ];
      }
      { service = "light.turn_on";
        data = {
          rgb_color= [255 0 0];
          effect = "0";
          entity_id =  [ "light.status_felix" ];
        };
      }
    ];
  }
  ]
  ;
  script =  lib.fold lib.recursiveUpdate {} (
    (map (ab: buzz_user ab.fst ab.snd) (lib.zipLists persons patterns)) ++
    (map (p: announce_user p) persons) ++
    (map (p: zu_lange_user p) persons) ++
    [ (announce_user "felix" ) (buzz_user "felix" [125 250 500] ) ]
  );
}
