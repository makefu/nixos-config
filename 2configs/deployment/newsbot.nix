{ config, pkgs, ... }:

let
  newsfile = pkgs.writeText "feeds" ''
    nixoswiki-bot|https://github.com/Mic92/nixos-wiki/wiki.atom|#krebs
  '';
in {
  environment.systemPackages = [
    pkgs.newsbot-js
  ];
  krebs.newsbot-js = {
    enable = true;
    ircServer = "chat.freenode.net";
    feeds = newsfile;
    urlShortenerHost = "go";
    urlShortenerPort = "80";
  };
}
