
let
in {
  services.home-assistant.config.tts = [
        { platform = "google_translate";
          language = "de";
          time_memory = 57600;
          service_name =  "google_say";
        }
        #{ platform = "google_cloud";
        #  key_file = toString <secrets/googlecloud.json>;
        #  service_name =  "cloud_say";
        #  language = "de-DE";
        #  voice = "de-DE-Wavenet-B";
        #  profiles = [ "medium-bluetooth-speaker-class-device" ];
        #}
    ];
}
