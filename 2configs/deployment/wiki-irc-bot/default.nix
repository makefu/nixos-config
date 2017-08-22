{ config, pkgs, ... }:

let
  pkg = pkgs.lib.overrideDerivation pkgs.newsbot-js (original: {
    patches = [ ./wiki-output.patch ];
  });
  newsfile = pkgs.writeText "feeds" ''
    nixoswiki-bot|https://nixos.wiki/api.php?days=7&limit=50&hidecategorization=1&action=feedrecentchanges&feedformat=rss|#krebs
  '';
in {
  krebs.newsbot-js = {
    enable = true;
    package = pkg;
    ircServer = "chat.freenode.net";
    feeds = newsfile;
    urlShortenerHost = "go";
    urlShortenerPort = "80";
  };
}
