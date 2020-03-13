{
  home-manager.users.makefu = {
    programs.mbsync.enable = true;
    accounts.email.maildirBasePath =  "/home/makefu/Mail";
    accounts.email.certificatesFile = "/etc/ssl/certs/ca-certificates.crt";
    accounts.email.accounts.syntaxfehler = {
      address = "felix.richter@syntax-fehler.de";
      userName = "Felix.Richter@syntax-fehler.de";
      imap = {
        host = "syntax-fehler.de";
        tls = {
          enable = true;
        };
      };
      mbsync = {
        enable = true;
        create = "both";
        remove = "both";
        expunge = "both";
        patterns = [ "*" "!INBOX.Sent*"];
      };
      smtp = {
        host = "syntax-fehler.de";
        tls = {
          enable = true;
        };
      };
      folders = {
        sent = "Sent";
        trash = "Trash";
        inbox = "INBOX";
        drafts = "Drafts";
      };
      msmtp.enable = true;
      notmuch.enable = true;
      offlineimap = {
        enable = true;
        postSyncHookCommand = "notmuch new";
        extraConfig.remote = {
          auth_mechanisms = "LOGIN";
          tls_level = "tls_secure";
          ssl_version = "tls1_2";
          holdconnectionopen = true;
          idlefolders = "['INBOX']";
        };
      };
      primary = true;
      realName = "Felix Richter";
      passwordCommand = "gpg --use-agent --quiet --batch -d /home/makefu/.gnupg/mail/syntax-fehler.gpg";
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
