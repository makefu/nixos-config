let
  firetv_stick = "192.168.111.24";
in {
  services.home-assistant.config = {
    notify = [
      {
      platform = "nfandroidtv";
      name = "FireTV Wohnzimmer Notification";
      host = firetv_stick;
      }
    ];
    media_player = [
        #{
        #  platform = "kodi";
        #  name = "FireTV Stick kodi";
        #  host = firetv_stick;
        #}
        # Configuration needs to be done by hand via web interface "integration"
        { platform = "androidtv";
          name = "FireTV Stick Android";
          device_class = "firetv";
          host = firetv_stick;
          port = 5555;
        }
      ];
    };
  }
