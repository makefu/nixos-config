{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
let
  gold = pkgs.fetchFromGitHub {
    owner = "krebs";
    repo = "krebsgold";
    rev = "15f7a74";
    sha256= "1ya9xgg640k3hbl63022sfm44c1si2mxch8jkxindmwg4pa1y4ly";
  };
in {

  services.nginx = {
    enable = mkDefault true;
    virtualHosts = {
      "gold.krebsco.de" = {
        enableACME = true;
        forceSSL = true;
        root = toString gold + "/html";
      };
    };
  };
}

