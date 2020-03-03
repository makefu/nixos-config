[
  {
    alias = "Nightly reboot of firetv";
    trigger = {
      platform = "time";
      at = "03:00:00";
    };
    action = [
      {
        service = "androidtv.adb_command";
        data = {
          entity_id = "media_player.firetv_stick";
          command = "reboot";
        };
      }
      { delay.minutes = 2; }
      {
        service = "media_player.select_source";
        data = {
          entity_id = "media_player.firetv_stick";
          source = "com.amazon.bueller.music";
        };
      }
    ];
  }
]
