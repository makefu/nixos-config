{ config, lib, pkgs, ... }:
# more than just nginx config but not enough to become a module
let
  wsgi-sock = "${workdir}/uwsgi-photostore.sock";
  workdir = config.services.uwsgi.runDir;
  wifi-itf = "wlp2s0";
  wifi-ip = "172.16.9.96";
in {

  services.uwsgi = {
    enable = true;
    user = "nginx";
    runDir = "/var/lib/photostore";
    plugins = [ "python3" ];
    instance = {
      type = "emperor";
      vassals = {
        cameraupload-server = {
          type = "normal";
          pythonPackages = self: with self; [ pkgs.cameraupload-server ];
          socket = wsgi-sock;
        };
      };
    };
  };

  services.nginx = {
    enable = lib.mkDefault true;
    virtualHosts.${wifi-ip} = {
      locations = {
        "/".extraConfig = ''
        expires -1;
        uwsgi_pass                  unix://${wsgi-sock};
        uwsgi_param UWSGI_CHDIR     ${workdir};
        uwsgi_param UWSGI_MODULE    cuserver.main;
        uwsgi_param UWSGI_CALLABLE  app;
        include                     ${pkgs.nginx}/conf/uwsgi_params;
      '';
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
#  networking.interfaces.${wifi-itf}.ipv4.addresses = [{
#    address = wifi-ip;
#    prefixLength = 24;
#  }];

  networking.wireless = {
    enable = true;
    interfaces = [ wifi-itf ];
    networks.Mobility = {
      priority = -999;
      psk = null;
    };
  };
}
