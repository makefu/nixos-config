let
  cmd = command: {
        service = "androidtv.adb_command";
        data = {
          entity_id = "media_player.firetv_stick";
          inherit command;
        };
      };
  sec = seconds: { delay.seconds = seconds; };
in
{
  services.home-assistant.config.automation =
  [
    {
      alias = "Nightly reboot of firetv";
      trigger = {
        platform = "time";
        at = "03:00:00";
      };
      action = [
        (cmd "reboot")
        (sec 90) # go to my music because apparently select_source does not seem to always work
        #(cmd "HOME")
        #(sec 2)
        #(cmd "DOWN")
        #(sec 2)
        #(cmd "DOWN")
        #(sec 2)
        #(cmd "ENTER")
        #(sec 4)
        #(cmd "RIGHT")
        #(sec 2)
        #(cmd "RIGHT")
      ];
    }
  ];
}
