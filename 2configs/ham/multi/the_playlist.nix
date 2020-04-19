{
  sensor =  [
    { platform = "rest";
      name = "pl";
      resource = "http://prism.r:8001/current";
      scan_interval = 30;
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
