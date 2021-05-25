{ pkgs, ... }: {
  systemd.services.brockman.environment."BROCKMAN_LOG_LEVEL" = "DEBUG";
  systemd.services.restart-brockman = {
    after = [ "brockman.service" ];
    wantedBy = [ "multi-user.target" ];
    startAt = "daily";
    script = "${pkgs.systemd}/bin/systemctl try-restart brockman.service";
  };
  krebs.brockman = {
    enable = true;
    config = {
      channel = "#systemdultras";
      irc = {
        host = "irc.hackint.org";
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
