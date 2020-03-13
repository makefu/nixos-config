{ config, lib, pkgs, ... }:
# more than just nginx config but not enough to become a module
let
  wsgi-sock = "${workdir}/uwsgi-gecloudpad.sock";
  workdir = config.services.uwsgi.runDir;
  gecloudpad = pkgs.python3Packages.callPackage ./gecloudpad.nix {};
in {

  services.uwsgi = {
    enable = true;
    user = "nginx";
    # runDir = "/var/lib/photostore";
    plugins = [ "python3" ];
    instance = {
      type = "emperor";
      vassals = {
        gecloudpad = {
          type = "normal";
          pythonPackages = self: with self; [ gecloudpad ];
          socket = wsgi-sock;
        };
      };
    };
  };

  services.nginx = {
    enable = lib.mkDefault true;
    virtualHosts."pad.binaergewitter.de" = {
      enableACME = true;
      forceSSL = true;
      locations = {
        "/".extraConfig = ''
        expires -1;
        uwsgi_pass                  unix://${wsgi-sock};
        uwsgi_param UWSGI_CHDIR     ${gecloudpad}/${pkgs.python.sitePackages};
        uwsgi_param UWSGI_MODULE    gecloudpad.main;
        uwsgi_param UWSGI_CALLABLE  app;
        include                     ${pkgs.nginx}/conf/uwsgi_params;
      '';
      };
    };
  };
}
