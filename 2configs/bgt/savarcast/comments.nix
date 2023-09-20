{ config, pkgs, lib, ... }:
let
  configFile = config.sops.secrets."isso.conf".path;
  searchdir = "/var/www/search";
in {

  sops.secrets."isso.conf" = {
    owner = "isso";
    group = "isso";
  };

  users.users.isso = {
    group = "isso";
    isSystemUser = true;
  };

  users.users.stork = {
    group = "stork";
    isNormalUser = true;
    home = searchdir;
    createHome = false;
    openssh.authorizedKeys.keys = [
      # GitHub deploy search (bgt_github_deploy.pub)
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGrj6cLVxv6LR0INj2OL/EVdEFMZSk0fOc0pCeXVTirz hi@l33t.name"
    ];
  };

  users.groups.isso = {};

  systemd.tmpfiles.rules = [ "d ${searchdir} 0770 stork nginx - -" ];

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

  services.nginx.virtualHosts."search.binaergewitter.de" = {
    locations."/" = {
      root = "/var/www/search/";
      tryFiles = "/bgt.st =404"; 
    };
  };
  # savarcast is behind traefik, do not configure tls
  services.nginx.virtualHosts."comments.binaergewitter.de" = {
    locations."= /bgt.st".root = "/var/www/search/";
    locations."/".proxyPass = "http://localhost:9292";
  };

}
