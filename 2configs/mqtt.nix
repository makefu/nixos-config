{ ... }:
{
  services.mosquitto = {
    enable = true;
    host = "0.0.0.0";
    users = {};
    allowAnonymous = true;
  };
}
