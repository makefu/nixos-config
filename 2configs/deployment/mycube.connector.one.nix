{ config, lib, pkgs, ... }:
# more than just nginx config but not enough to become a module
with config.krebs.lib;
let
  hostname = config.krebs.build.host.name;
  external-ip = config.krebs.build.host.nets.internet.ip4.addr;
  wsgi-sock = "${config.services.uwsgi.runDir}/uwsgi.sock";
in {
  services.redis = {
    enable = true;
  };
  systemd.services.redis.serviceConfig.LimitNOFILE=10032;

  services.uwsgi = {
    enable = true;
    user = "nginx";
    plugins = [ "python2" ];
    instance = {
      type = "emperor";
      vassals = {
        mycube-flask = {
          type = "normal";
          pythonPackages = self: with self; [ pkgs.mycube-flask ];
          socket = wsgi-sock;
        };
      };
    };
  };

  krebs.nginx = {
    enable = mkDefault true;
    servers = {
      mybox-connector-one = {
        listen = [ "${external-ip}:80" ];
        server-names = [
          "mycube.connector.one"
          "mybox.connector.one"
        ];
        locations = singleton (nameValuePair "/" ''
          uwsgi_pass unix://${wsgi-sock};
          uwsgi_param         UWSGI_CHDIR     ${pkgs.mycube-flask}/${pkgs.python.sitePackages};
          uwsgi_param         UWSGI_MODULE    mycube.websrv;
          uwsgi_param         UWSGI_CALLABLE  app;

          include ${pkgs.nginx}/conf/uwsgi_params;
        '');
      };
    };
  };
}
