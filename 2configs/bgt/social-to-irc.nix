{
  # systemd.services.brockman.environment."BROCKMAN_LOG_LEVEL" = "DEBUG";
  krebs.brockman = {
    enable = true;
    config = {
      channel = "#binaergewitter";
      irc = {
        host = "irc.freenode.net";
        port = 6667;
      };
      #controller = {
      #  nick = "brockman-systemdultras";
      #  channels = [];
      #};
      bots = {
        bgt-mastodon-rss = {
          feed = "https://jit.social/users/binaergewitter.rss";
          channels = [ "#binaergewitter" ];
          delay = 180;
          notifyErrors = false;
        };
        bgt-blog-rss = {
          feed = "https://blog.binaergewitter.de/rss.xml";
          channels = [ "#binaergewitter" ];
          delay = 180;
          notifyErrors = false;
        };
      };
    };

  };
}
