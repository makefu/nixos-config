{
  services.moonraker = {
    enable = true;
    address = "0";
    settings = {
      octoprint_compat = {};
      history = {};

    };
  };

  services.fluidd.enable = true;
  services.fluidd.nginx.locations."/webcam".proxyPass = "http://127.0.0.1:8080/stream";
  services.nginx.clientMaxBodySize = "1000m";

  services.klipper = {
    enable = true;
    firmwares = {
      artillery = {
        enable = true;
      };
    };
  };
}
