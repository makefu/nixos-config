{
  systemd.services.brockman.environment."BROCKMAN_LOG_LEVEL" = "DEBUG";
  krebs.brockman = {
    enable = true;
    config = {
      channel = "#systemdultras";
      irc = {
        host = "irc.freenode.net";
        port = 6667;
      };
      notifyErrors = false;
      bots = {
        r-systemdultras-rss = {
          feed = "https://www.reddit.com/r/systemdultras/.rss";
          delay = 136;
        };
        r-systemd-rss = {
          feed = "https://www.reddit.com/r/systemd/.rss";
          delay = 172;
        };
      };
    };

  };
}
