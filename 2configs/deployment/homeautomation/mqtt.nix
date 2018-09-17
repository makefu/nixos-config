{ pkgs, config, ... }:
{
  services.mosquitto = {
    enable = true;
    host = "0.0.0.0";
    allowAnonymous = false;
    checkPasswords = true;
    # see <host>/mosquitto
    users.sensor = {
      hashedPassword = "$6$2DXU7W1bvqXPqxkF$vtdz5KTd/T09hmoc9LjgEGFjvpwQbQth6vlVcr5hJNLgcBHv4U03YCKC8TKXbmQAa8xiJ76xJIg25kcL+KI3tg==";
      acl = [ "topic readwrite #" ];
    };
  };
  environment.systemPackages = [ pkgs.mosquitto ];
  networking.firewall.allowedTCPPorts = [ config.services.mosquitto.port ];
}
