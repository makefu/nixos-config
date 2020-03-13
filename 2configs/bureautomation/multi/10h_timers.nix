{lib, ... }:
let
  persons = [ "frank"  "daniel" "thorsten" "carsten" "ecki" "felix"
  "thierry" # tjeri
  "emeka"
  "tancrede"
  ];
  random_zu_lange = name: ''{{ [
    "Du musst jetzt endlich nach Hause gehen ${name}!",
    "${name} - 10 Stunden sind rum, bald schenkst du den Franzosen deine Lebenszeit",
    "Nur eine Minute über 10 Stunden kann zu einer Stunde Arbeit für Thorsten werden, ${name}.",
    "In 10 Minuten kommt dich der Security Mann holen, ${name}",
    "Das Sandmännchen ist schon vorbei, gleich fallen dir die Augen zu ${name}.",
    "Wenn ${name} sofort los geht, dann ist er noch rechtzeitig für den Tatort zu Hause.",
    "${name} muss jetzt gehen, sonst verpasst er die Tagesschau!",
    "Es ist spät ${name}. Ausstempeln hilft zwar kurzfristig, kann aber zu langfristigen Problemen führen.",
    "${name}, wenn du nach zehn Stunden nach Hause gehst, muss dir dein Vorgesetzter ein Taxi bestellen",
    "${name}, wenn du nach zehn Stunden nach Hause gehst, bist du auf dem Rückweg nicht mehr versichert!",
    "Zu lange, ${name}!" ] | random }}'' ;


  random_announce = name: ''{{ [
    "${name} is in da House",
    "Ahoi ${name}",
    "Hallöchen Popöchen ${name}",
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
    "Ich kenne ein Geheimnis, ${name} ist angekommen",
    "Wir sind ${name}. Sie werden assimiliert werden",
    "Achtung, es erfolgt eine Durchsage. ${name} ist eingetroffen",
    "Die Scanner haben eine dem System bekannte Lebensform mit dem Namen ${name} detektiert",
    "Das Büro sieht dich, ${name}",
    "Das Büro riecht dich, ${name}",
    "Im Kalender von ${name} sind heute acht Meetings eingeplant, von denen zwei bereits verpasst wurden",
    "Das Postfach von ${name} beinhaltet einhundertachtundzwanzig ungelesene E-Mails.",
    "Nachricht von Serge: ${name}, bitte melden Sie sich Umgehend bei mir im Büro!",
    "Luftqualität hat sich durch das Eintreffen von ${name} um zweihundert Punkte verschlechtert, bitte alle Fenster öffnen.",
    "Die Tür geht auf, wer mag das sein? Schon schreitet hier der ${name} ein. Das Volk, es jubelt, Dirnen schmachten. Fürs Festmahl beginnt man schon zu schlachten. Er wird nur nach dem besten streben! Der ${name}, er soll lange leben!",
    "${name} arbeitet gern für seinen Konzern",
    "${name} ist nur froh im Großraumbüro",
    "Für ${name} ist die schönste Zeit ... die Arbeit",
    "Ein Fleißbienchen für ${name} zum rechtzeitigen Erscheinen im Büro",
    "${name} ist heute wohl doch nicht im Office Home",
    "${name} ist bereit für einen Tag voller Meetings",
    "Und es startet für ${name} wieder ein Tag im Paradies",
    "Lieber ${name}, Markus Keck hat dich bereits drei mal Versucht anzurufen!",
    "Trotz schwerer Männergrippe ist ${name} heute im Büro erschienen.",
    "${name} kennt keine Parteien mehr, ${name} kennt nur noch Arbeitsplätze",
    "${name}, Frage nicht, was dein Arbeitsplatz für dich tun kann. Frage, was du für deinen Arbeitsplatz tun kannst",
    "${name} läuft bis in den Jemen - für sein Unternehmen. ${name} schwimmt bis nach Birma - für seine Firma",
    "Der Cyberian ${name} ist gekommen um die Bahnwelt vor Cyber-Angriffen zu schützen",
    "Alles paletto im Ghetto, ${name}?",
    "Hach, ${name}, wenn du hier rein kommst fühlt es sich gleich wieder an wie Montag.",
    "Oh nein, nicht schon wieder ${name}",
    "Wer wohnt in der Ananas ganz tief im Meer? ${name} Schwammkopf!",
    "Arbeit ist Freizeit! Wachstum ist Fortschritt! Sicherheit ist Freiheit! Eine kleine Erinnerung für ${name}"] | random }}'' ;
  tmr_10h = name: {
    "${name}_10h" = {
      name = "${name} 10h Timer";
      duration = "10:00:00";
    };
  };

  zu_lange_user = name:
  { "zu_lange_${name}" = {
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
        { delay.seconds = 7; }
        { service = "media_player.play_media";
          data = {
            entity_id = "media_player.mpd";
            media_content_type = "playlist";
            media_content_id = "ansage";
          };
        }
        { delay.seconds = 4; }
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
        entity_id = [ "person.${name}"];
        from =  "not_home";
        to = "home";
      };
      condition = {
        condition = "and";
        conditions = [
          { condition = "state";
            entity_id = "timer.${name}_10h";
            state =  "idle";
          }
          { condition = "time";
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
          entity_id =
          [ "switch.fernseher"
            "script.blitz_10s"
            "script.announce_${name}"
          ];
        }
      ];
    }

    { alias = "pommes announce ${name}";
      trigger =
      { platform = "event";
        event_type = "timer.started";
        event_data.entity_id = "timer.${name}_10h";
      };

      condition =
      { condition = "state";
        entity_id = "binary_sensor.pommes";
        state =  "on";
      };

      action =
      { service = "homeassistant.turn_on";
        entity_id = "script.blasen_10s" ;
      };
    }

    { alias = "Zu lange ${name}!";
      trigger =
      { platform = "event";
        event_type = "timer.finished";
        event_data.entity_id = "timer.${name}_10h";
      };

      condition =
      { condition = "state";
        entity_id = "person.${name}";
        state = "home";
      };

      action =
      { service = "homeassistant.turn_on";
        entity_id =  [
          "script.blitz_10s"
          "script.zu_lange_${name}"
        ];
      };
    }
  ];
in
{
  timer =lib.fold lib.recursiveUpdate {}
    (map tmr_10h persons);
  automation = (lib.flatten (map automation_10h persons));
  script =  lib.fold lib.recursiveUpdate {} (
    (map announce_user persons) ++
    (map zu_lange_user persons)
  );
}
