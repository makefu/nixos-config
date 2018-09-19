{
  home-manager.users.makefu = {
    accounts.email.accounts.syntaxfehler = {
      address = "felix.richter@syntax-fehler.de";
      userName = "Felix.Richter@syntax-fehler.de";
      imap = {
        host = "syntax-fehler.de";
        tls = {
          enable = true;
        };
      };
      smtp = {
        host = "syntax-fehler.de";
        tls = {
          enable = true;
        };
      };
      msmtp.enable = true;
      notmuch.enable = true;
      offlineimap = {
        enable = true;
        postSyncHookCommand = "notmuch new";
        extraConfig.remote = {
          holdconnectionopen = true;
          idlefolders = "['INBOX']";
        };
      };
      primary = true;
      realName = "Felix Richter";
      passwordCommand = "gpg --use-agent --quiet --batch -d /home/makefu/.mail/syntax-fehler.gpg";
    };
    programs.offlineimap.enable = true;
    programs.offlineimap.extraConfig = {
      mbnames = {
        filename = "~/.mutt/muttrc.mailboxes";
        header = "'mailboxes '";
        peritem = "'+%(accountname)s/%(foldername)s'";
        sep = "' '";
        footer = "'\\n'";
      };
      general = {
        ui = "TTY.TTYUI";
      };
    };
  };
}
