{ config, pkgs, ... }:
let
  # SMTP credential, stored as clan/sops secret `x-msmtp-password`
  # (machine x, user makefu). Never lands in the nix store; msmtp reads it
  # at send time from /run/secrets.
  passwordFile = config.sops.secrets.x-msmtp-password.path;

  # GNU mailutils `mail` pipes the full message (incl. To/Subject headers)
  # to the `sendmail` program but does NOT pass recipients on argv, so plain
  # msmtp errors with "no recipients found". `-t` makes msmtp read the
  # recipients from the message headers. Distinct name avoids colliding with
  # msmtp's own bin/sendmail in the home profile.
  mailSendmail = pkgs.writeShellScriptBin "msmtp-sendmail" ''
    exec ${pkgs.msmtp}/bin/msmtp -t "$@"
  '';
in
{
  sops.secrets.x-msmtp-password = {
    owner = "makefu";
    mode = "0400";
  };

  home-manager.users.makefu = {
    home.packages = with pkgs; [
      mailutils
      mailSendmail
      (pkgs.writers.writeDashBin "mailsync" ''
        ${imapfilter}/bin/imapfilter -t /etc/ssl/certs/ca-bundle.crt  \
          && ${isync}/bin/mbsync -a  \
          && ${libnotify}/bin/notify-send -t 1000000 -u critical 'Mail sync finished'

      ''
      )
    ];

    # Route mailutils `mail` through the msmtp -t wrapper so
    #   echo hello | mail -s "test mail" me@syntax-fehler.de
    # delivers via the configured account.
    home.file.".mailrc".text = ''
      set sendmail="${mailSendmail}/bin/msmtp-sendmail"
    '';

    programs.mbsync.enable = true;
    programs.msmtp.enable = true;
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
        port = 25;
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
      msmtp = {
        enable = true;
        # upstream submission cert fails the default check; the original
        # ~/.msmtprc disabled it, keep parity.
        extraConfig.tls_certcheck = "off";
      };
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
      passwordCommand = "cat ${passwordFile}";
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
