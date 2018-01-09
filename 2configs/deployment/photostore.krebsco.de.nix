{ config, lib, pkgs, ... }:
# more than just nginx config but not enough to become a module
with import <stockholm/lib>;
let
  wsgi-sock = "${workdir}/uwsgi-photostore.sock";
  workdir = config.services.uwsgi.runDir;
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
    enable = mkDefault true;
    virtualHosts."photostore.krebsco.de" = {
        locations = {
          "/".extraConfig = ''
          uwsgi_pass                  unix://${wsgi-sock};
          uwsgi_param UWSGI_CHDIR     ${workdir};
          uwsgi_param UWSGI_MODULE    cuserver.main;
          uwsgi_param UWSGI_CALLABLE  app;
          include                     ${pkgs.nginx}/conf/uwsgi_params;
        '';
      };
    };
  };
}
