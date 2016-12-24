{ config, pkgs, lib, ... }:

with import <stockholm/lib>;

let
  icecult = pkgs.fetchFromGitHub {
    owner = "kraiz";
    repo = "icecult";
    rev = "1942d43381a97f30111a48725f7532c343a6f4d7";
    sha256 = "0l8q7kw3w1kpvmy8hza9vr5liiycivbljkmwpacaifbay5y98z58";
  };
in{
  services.nginx = {
    enable = true;
    virtualHosts.default = {
      root = "${icecult}/app";
      locations = {
        "/rpc".proxyPass = "http://10.42.22.163:3121";
        "/rpc".extraConfig = ''
          rewrite /rpc/(.*) /$1 break;
          proxy_http_version 1.1;
        '';
      };
    };
  };
}
