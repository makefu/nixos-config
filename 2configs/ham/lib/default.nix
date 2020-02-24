let
  prefix = "/ham";
in
{
  inherit prefix;
  say = let
    # returns a list of actions to be performed on an mpd to say something
    tts = { message, entity }:
    [
      {
        service = "media_player.turn_on";
        data.entity_id = entity;
      }
      {
        service = "media_player.play_media";
        data = {
          entity_id = entity;
          media_content_type = "playlist";
          media_content_id = "ansage";
        };
      }
      {
        service = "media_player.turn_on";
        data.entity_id = entity;
      }
      { delay.seconds = 8; }
      {
        service = "tts.say";
        entity_id =  entity;
        data_template = {
          inherit message;
          language = "de";
        };
      }
    ];
  in
  {
    firetv = message: tts {
      inherit message;
      entity = "firetv";
    };
  };
}
