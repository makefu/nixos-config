{ config, pkgs, lib, ... }:
let
  configFile = config.sops.secrets."isso.conf".path;
in {

  sops.secrets."isso.conf" = {
    owner = "isso";
    group = "isso";
  };

  users.users.isso = {
    group = "isso";
    isSystemUser = true;
  };

  users.groups.isso = {};

  services.isso.enable = true;
  # override the startup to allow secrets in the configFile
  # following relevant config is inside:
  # [general]
  # dbpath = /var/lib/comments.db
  # host = https://blog.binaergewitter.de
  # listen = http://localhost:9292
  # public-endpoint = https://comments.binaergewitter.de
  systemd.services.isso.serviceConfig.ExecStart = lib.mkForce "${pkgs.isso}/bin/isso -c ${configFile}" ;
  systemd.services.isso.serviceConfig.DynamicUser = lib.mkForce false;

  # savarcast is behind traefik, do not configure tls
  services.nginx.virtualHosts."comments.binaergewitter.de" = {
    locations."/".proxyPass = "http://localhost:9292";
  };

}
