{
  services.home-assistant.config = {
    intent_script = {
      GetTime.speech.text = ''
        Es ist {{ now().hour }} Uhr {{ now().minute }}
      '';
      GutenMorgen.speech.text = ''
        Einen wunderschönen Guten Morgen wünsche ich dir
      '';
      WieGehtEsDir.speech.text = ''
        Mir geht es sehr gut, und dir?
      '';
      Statusreport.speech.text = builtins.readFile ./statusbericht.txt.j2;
      StartMusic = {
        speech.text = "Spiele {{ music }} musik";
        action_async = [
          {
            service = "media_player.play_media";
            data_template = {
              entity_id = "media_player.{{ _intent.siteId }}";
              media_content_id = builtins.readFile ./music_chooser.txt.j2;
              media_content_type = "music";
            };
          }
        ];
      };
      GetWeather = {
        #speech.text = ''
        #  {{ states('sensor.openweathermap_weather') }} bei {{ states('sensor.openweathermap_temperature') }} Grad
        #'';
        speech.text = "{{ states('sensor.swr_prognose') }}";
      };
    };
  };
}
