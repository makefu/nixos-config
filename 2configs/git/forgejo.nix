{ lib, pkgs, config, ... }:
let
  DOMAIN = "cgit.euer.krebsco.de";
  HTTP_PORT = 3002;
in
  {
  services.nginx = {
    virtualHosts."cgit.euer" = {
      serverAliases = [
        "cgit.gum.r"
        "git.gum.r"
        "cgit.makefu.r"
        "git.makefu.r"
      ];
      globalRedirect = "cgit.euer.krebsco.de";
    };
    virtualHosts.${DOMAIN} = {
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        client_max_body_size 512M;
      '';
      locations."/".proxyPass = "http://localhost:${toString HTTP_PORT}";
    };
  };
  
  services.forgejo = {
    enable = true;
    database.type = "postgres";
    lfs.enable = true;
    settings = {
      server = {
        # You need to specify this to remove the port from URLs in the web UI.
        ROOT_URL = "https://${DOMAIN}/"; 
        inherit HTTP_PORT DOMAIN;
      };
      # You can temporarily allow registration to create an admin user.
      service.DISABLE_REGISTRATION = true; 
      # Add support for actions, based on act: https://github.com/nektos/act
      actions = {
        ENABLED = true;
        DEFAULT_ACTIONS_URL = "github";
      };
      log.LEVEL = "Warn";
      # Sending emails is completely optional
      # You can send a test email from the web UI at:
      # Profile Picture > Site Administration > Configuration >  Mailer Configuration 
      #mailer = {
      #  ENABLED = true;
      #  SMTP_ADDR = "mail.example.com";
      #  FROM = "noreply@${srv.DOMAIN}";
      #  USER = "noreply@${srv.DOMAIN}";
      #};
    };
    #mailerPasswordFile = config.sops.secrets.forgejo-mailer-password.path;
  };

  sops.secrets.forgejo-admin-password.owner = "forgejo";
  # systemd.services.forgejo.serviceConfig.ReadOnlyPaths = [ config.sops.secrets.forgejo-admin-password ];
  systemd.services.forgejo.preStart = ''
    admin="${lib.getExe config.services.forgejo.package} admin user"
    $admin change-password --username makefu --password "$(tr -d '\n' < ${config.sops.secrets.forgejo-admin-password.path})" || true
    # $admin create --admin --email "makefu@x.r" --username makefu --password "$(tr -d '\n' < ${config.sops.secrets.forgejo-admin-password.path})" || true
  '';
}
