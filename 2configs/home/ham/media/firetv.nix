let
  firetv_stick = "192.168.111.24";
in {
  services.home-assistant.config = {
    notify = [
      #{
      #  platform = "kodi";
      #  name = "Kodi Wohnzimmer";
      #  host = firetv_stick;
      #}
      {
      platform = "nfandroidtv";
      name = "FireTV Wohnzimmer";
      host = firetv_stick;
      }
    ];
    media_player = [
        #{
        #  platform = "kodi";
        #  name = "FireTV Stick kodi";
        #  host = firetv_stick;
        #}
        { platform = "androidtv";
        name = "FireTV Stick";
        device_class = "firetv";
          # adb_server_ip = firetv_stick;
          host = firetv_stick;
          port = 5555;
        }
      ];
    };
  }
