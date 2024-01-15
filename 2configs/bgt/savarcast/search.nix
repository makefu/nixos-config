{ config, pkgs, lib, ... }:
let
  searchdir = "/var/www/search";
in {
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
  users.groups.stork = {};

  systemd.tmpfiles.rules = [ "d ${searchdir} 0770 stork nginx - -" ];

  # savarcast is behind traefik, do not configure tls
  services.nginx.virtualHosts."search.binaergewitter.de" = {
    locations."/" = {
      extraConfig = ''
        add_header Access-Control-Allow-Origin *;
'';
      root = "/var/www/search/";
      tryFiles = "/bgt.st =404"; 
    };
  };
}
