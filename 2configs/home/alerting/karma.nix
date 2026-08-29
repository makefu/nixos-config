# Karma: alert dashboard over the local alertmanager.
{ ... }:
{
  services.karma = {
    enable = true;
    settings = {
      # karma polls alertmanager every 30s and logs six info lines per poll
      log.level = "warning";
      listen = {
        address = "127.0.0.1";
        port = 9094;
      };
      alertmanager.servers = [{
        name = "omo";
        uri = "http://127.0.0.1:9093";
      }];
    };
  };
}
