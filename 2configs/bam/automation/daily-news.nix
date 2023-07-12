[
  {
    alias = "Daily news for Felix";
    trigger = {
      platform = "time";
      at = "07:35:00";
    };
    action = 
    [
      {
        service = "notify.telegrambot";
        data_template = {
          title = "Daily News";
          # TODO
          message = "";
        };
      }
    ];
  }
]
