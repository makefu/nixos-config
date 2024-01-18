{
  security.polkit.enable = true;
  services.moonraker = {
    enable = true;
    allowSystemControl = true;
    settings = {
      octoprint_compat = {};
      history = {};
      announcements.subscriptions = [ "fluidd" ];
      authorization = {
        trusted_clients = [ "192.168.111.0/24" "127.0.0.1" ];
        force_logins =  false;
        cors_domains = [ "http://fluidd.lan" "http://localhost" ];
      };
    };
  };
  #services.mainsail.enable = true;

  services.fluidd.enable = true;
  services.fluidd.hostName = "fluidd.lan";
  
  services.fluidd.nginx.locations."/webcam".proxyPass = "http://127.0.0.1:8080/stream";
  services.nginx.clientMaxBodySize = "1000m";

  services.klipper = {
    enable = true;
    user = "moonraker";
    group = "moonraker";
    # octoprintIntegration = true;

    # https://github.com/Klipper3d/klipper/blob/master/config/printer-artillery-sidewinder-x2-2022.cfg
    configFile = ./printer-artillery-sidewinder-x2-2022.cfg; # file used to control the klipper-flashed printer
    firmwares = {
      artillery = {
        enable = true;
        enableKlipperFlash = true;
        configFile = ./artillery-flashconfig; # file used to flash a printer with new klipper firmware
        serial = "/dev/ttyAMA0"; #when in DFU mode
      };
    };
  };
}
