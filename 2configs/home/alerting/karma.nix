# Karma: alert dashboard over the local alertmanager.
{ ... }:
{
  services.karma = {
    enable = true;
    settings = {
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
