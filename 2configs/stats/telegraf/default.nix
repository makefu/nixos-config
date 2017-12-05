{...}:
let
  url = "http://localhost:8086";
in {
  services.telegraf = {
    enable = true;
    extraConfig = {
      agent.debug = true;
      outputs = {
        influxdb = [{
          urls = [ url ];
          database = "telegraf";
        }];
      };
    };
  };
}
