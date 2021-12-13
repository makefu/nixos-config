{ pkgs, ... }:
{
  systemd.services.brockman.environment."BROCKMAN_LOG_LEVEL" = "DEBUG";
  krebs.brockman = {
    enable = true;
    config = {
      channel = "#binaergewitter";
      notifyErrors = false;
      irc = {
        host = "irc.libera.chat";
        port = 6667;
      };
      #controller = {
      #  nick = "brockman-systemdultras";
      #  channels = [];
      #};
      bots = {
        bgt-mastodon-rss = {
          feed = "https://jit.social/users/binaergewitter.rss";
          #extraChannels = [ "#binaergewitter" ];
          delay = 180;
        };
        bgt-blog-rss = {
          feed = "https://blog.binaergewitter.de/rss.xml";
          #extraChannels = [ "#binaergewitter" ];
          delay = 180;
        };
        bgt-twitter = {
          feed = "http://rss.makefu.r/?action=display&bridge=Twitter&context=By+username&u=binaergewitter&format=Atom";
          #extraChannels = [ "#binaergewitter" ];
          delay = 180;
        };
      };
    };

  };
}
