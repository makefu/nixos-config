{ ... }:
{
  services.mosquitto = {
    enable = true;
    host = "0.0.0.0";
    users = {};
    # TODO: secure that shit
    allowAnonymous = true;
  };
}
