{ config, pkgs, ... }:
{
  imports = [
    (builtins.fetchTarball "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/v2.2.1/nixos-mailserver-v2.2.1.tar.gz")
  ];

  mailserver = {
    enable = true;
    fqdn = "euer.eloop.org";
    domains = [ "euer.eloop.org" ];
    loginAccounts = {
        "makefu@euer.eloop.org" = {
            hashedPassword = "$6$5gFFAPnI/c/EHIx$3aHj64p5SX./C.MPb.eBmyLDRdWS1yaoV0s9r3Yexw4UO9URdUkBDgqT7F0Mjgt6.gyYaJ5E50h0Yg7iHtLWI/";
            aliases = [ "root@euer.eloop.org" ];
            catchAll = [ "euer.eloop.org" ];

        };
    };
    certificateScheme = 3;

    # Enable IMAP and POP3
    enableImap = true;
    enablePop3 = false;
    enableImapSsl = true;
    enablePop3Ssl = false;

    # Enable the ManageSieve protocol
    enableManageSieve = true;

    virusScanning = false;

  };

  services.dovecot2.extraConfig = ''
    ssl_dh = </var/lib/dhparams/dovecot2.pem
  '';
  state = [ # https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/wikis/A-Complete-Backup-Guide
    config.mailserver.mailDirectory
    config.mailserver.dkimKeyDirectory
  ];
  # workaround for DH creation
  # security.dhparams = {
  #   enable = true;
  #   params = {
  #     dovecot = 2048;
  #   };
  # };
  # systemd.services.dovecot2.requires = [ "dhparams-gen-dovecot.service" ];
  # systemd.services.dovecot2.after = [ "dhparams-gen-dovecot.service" ];
}

