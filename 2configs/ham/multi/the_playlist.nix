# Inputs:
#  binary_sensor.playlist_button_good
#  binary_sensor.playlist_button_bad

# outputs
#  rest_command
#  automation
#  sensor
{
  rest_command = {
    good_song = {
      url = "http://prism.r:8001/good";
      method = "POST";
    };
    bad_song = {
      url = "http://prism.r:8001/skip";
      method = "POST";
    };
  };
  automation = [
    {
      alias = "playlist song publish";
      trigger = {
        #platform = "event";
        #event_data.entity_id = "sensor.the_playlist_song";
        platform = "state";
        entity_id = "sensor.the_playlist_song";
      };
      action = {
        service = "mqtt.publish";
        data = {
          topic = "/ham/the_playlist/song";
          payload_template = "{{ states.sensor.the_playlist_song.state }}";
        };
      };
    }
    {
      alias = "playlist upvote on button";
      trigger = {
        platform = "state";
        entity_id = "binary_sensor.playlist_button_good";
        from = "off";
        to = "on";
      };
      action.service = "rest_command.good_song";
    }
    {
      alias = "playlist downvote on button";
      trigger = {
        platform = "state";
        entity_id = "binary_sensor.playlist_button_bad";
        from = "off";
        to = "on";
      };
      action.service = "rest_command.bad_song";
    }
  ];
  sensor =  [
    { platform = "rest";
      name = "pl";
      resource = "http://prism.r:8001/current";
      scan_interval = 30;
      value_template = "1";
      json_attributes = [ "name" "filename" "youtube" ];
    }
    { platform = "template";
      sensors = {
        the_playlist_song = {
          friendly_name = "Current Song";
          value_template = ''{{ states.sensor.pl.attributes['name'] }}'';
        };
        the_playlist_url = {
          friendly_name = "Song Youtube URL";
          value_template = ''{{ states.sensor.pl.attributes['youtube'] }}'';
        };
        the_playlist_filename = {
          friendly_name = "Song Filename";
          value_template = ''{{ states.sensor.pl.attributes['filename'] }}'';
        };
      };
    }
  ];
}
