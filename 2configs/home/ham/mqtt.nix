{ pkgs, config, ... }:
{
  environment.systemPackages = [ pkgs.mosquitto ];
  # port open via trusted interface
  services.mosquitto = {
    enable = true;
    persistence = false;
    settings.max_keepalive = 60;
    listeners = [
      {
        port = 1883;
        omitPasswordAuth = false;
        users.sensor = {
          hashedPassword = "$6$2DXU7W1bvqXPqxkF$vtdz5KTd/T09hmoc9LjgEGFjvpwQbQth6vlVcr5hJNLgcBHv4U03YCKC8TKXbmQAa8xiJ76xJIg25kcL+KI3tg==";
          acl = [ "topic readwrite #" ];
        };
        users.hass = {
          hashedPassword = "$6$SHuYGrE5kPSUc/hu$EomZ0KBy+vkxLt/6eJkrSBjYblCCeMjhDfUd2mwqXYJ4XsP8hGmZ59mMlmBCd3AvlFYQxb4DT/j3TYlrqo7cDA==";
          acl = [ "topic readwrite #" ];
        };
        users.stats = {
          hashedPassword = "$6$j4H7KXD/YZgvgNmL$8e9sUKRXowDqJLOVgzCdDrvDE3+4dGgU6AngfAeN/rleGOgaMhee2Mbg2KS5TC1TOW3tYbk9NhjLYtjBgfRkoA==";
          acl = [ "topic read #" ];
        };
        settings = {
          allow_anonymous = false;
        };
      }
    ];
  };
}
