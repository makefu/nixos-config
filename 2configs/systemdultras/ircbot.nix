{ pkgs, ... }: {
  systemd.services.brockman.environment."BROCKMAN_LOG_LEVEL" = "DEBUG";

  services.rss-bridge = {
    enable = true;
    whitelist = [ "*" ];
    virtualHost = "rss.makefu.r";
  };

  krebs.brockman = {
    enable = true;
    config = {
      channel = "#systemdultras";
      irc = {
        host = "irc.hackint.org";
        port = 6697;
        tls = true;
      };
      notifyErrors = false;
      bots = {
        r-systemdultras-rss = {
          feed = "https://www.reddit.com/r/systemdultras/.rss";
          delay = 236;
        };
        r-systemd-rss = {
          feed = "https://www.reddit.com/r/systemd/.rss";
          delay = 272;
        };
        r-pid_eins-mastodon = {
          feed = "https://mastodon.social/users/pid_eins.rss";
          delay = 621;
        };
      };
    };

  };
}
