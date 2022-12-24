{
  services.home-assistant.config.script = {
    find_felix_phone.sequence = [
      {
        service = "notify.mobile_app_pixel_3a";
        data = {
            title= "Finde Mich!";
            message= "Such Such Such";
            data = {
              ttl = 0;
              priority = "high";
              channel = "alarm_stream";
            };
        };
      }
    ];
    find_tablet.sequence = [
      {
        service = "notify.mobile_app_nova3";
        data = {
            title = "Finde Mich!";
            message = "Such Such Such";
            data = {
              ttl = 0;
              priority = "high";
              channel = "alarm_stream";
            };
        };
      }
    ];
  };
}
