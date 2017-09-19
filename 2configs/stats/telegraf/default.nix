{...}:
let
  url = "http://localhost:8086";
in {
  imports = [
    ./europastats.nix
  ];
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
