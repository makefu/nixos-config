{ config, pkgs, inputs, lib, ... }:
let
  configFile = config.sops.secrets."bgt-isso.conf".path;
  pkg = inputs.nixpkgs-stable.legacyPackages.${pkgs.system}.isso;
in {

  sops.secrets."bgt-isso.conf" = {
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
  systemd.services.isso.serviceConfig.ExecStart = lib.mkForce "${pkg}/bin/isso -c ${configFile}" ;
  systemd.services.isso.serviceConfig.DynamicUser = lib.mkForce false;

  # savarcast is behind traefik, do not configure tls
  services.nginx.virtualHosts."comments.binaergewitter.de" = {
    locations."/".proxyPass = "http://localhost:9292";
  };

}
