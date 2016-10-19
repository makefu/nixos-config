{ config, pkgs, lib, ... }:

with config.krebs.lib;

let
  icecult = pkgs.fetchFromGitHub {
    owner = "kraiz";
    repo = "icecult";
    rev = "1942d43381a97f30111a48725f7532c343a6f4d7";
    sha256 = "0l8q7kw3w1kpvmy8hza9vr5liiycivbljkmwpacaifbay5y98z58";
  };
in{
  krebs.nginx = {
    enable = true;
    servers.default = {
        extraConfig = ''
          root ${icecult}/app;
        '';
        locations = [
          (nameValuePair "/rpc" ''
        rewrite /rpc/(.*) /$1 break;
        proxy_http_version 1.1;
        proxy_pass http://10.42.22.163:3121;
          '')
      ];
    };
  };
}
