{ ... }:
{
  services.mosquitto = {
    enable = true;
    persistence = false;
    settings.max_keepalive = 60;
    listeners = [
      {
        port = 1883;
        omitPasswordAuth = true;
        users = {};
        settings = {
          allow_anonymous = true;
        };
        acl = [ "topic readwrite #" "pattern readwrite #" ];
      }
    ];
  };
}
