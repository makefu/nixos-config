{ config, lib, pkgs, ... }:
# more than just nginx config but not enough to become a module
with import <stockholm/lib>;
let
  external-ip = config.krebs.build.host.nets.internet.ip4.addr;
  wsgi-sock = "${config.services.uwsgi.runDir}/uwsgi.sock";
  elch-sock = "${config.services.uwsgi.runDir}/uwsgi-elch.sock";
in {

  services.uwsgi = {
    enable = true;
    user = "nginx";
    plugins = [ "python2" ];
    instance.type = "emperor";
  };
}
