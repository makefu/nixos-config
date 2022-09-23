{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
let
  ident = (builtins.readFile ./auphonic.pub);
  bgtaccess = "/var/spool/nginx/logs/binaergewitter.access.log";
  bgterror = "/var/spool/nginx/logs/binaergewitter.error.log";

  # TODO: only when the data is stored somewhere else
  wwwdir = "/var/www/binaergewitter";
  storedir = "/media/cloud/www/binaergewitter";
in {
  fileSystems."${wwwdir}" = {
    device = storedir;
    options = [ "bind" ];
  };

  services.openssh = {
    allowSFTP = true;
    sftpFlags = [ "-l VERBOSE" ];
    extraConfig = ''
      HostkeyAlgorithms +ssh-rsa

      Match User auphonic
        ForceCommand internal-sftp
        AllowTcpForwarding no
        X11Forwarding no
        PasswordAuthentication no
        PubkeyAcceptedAlgorithms +ssh-rsa

    '';
  };

  users.users.auphonic = {
    uid = genid "auphonic";
    group = "nginx";
    # for storedir
    extraGroups = [ "download" ];
    useDefaultShell = true;
    isSystemUser = true;
    openssh.authorizedKeys.keys = [ ident config.krebs.users.makefu.pubkey ];
  };

  services.logrotate = {
    enable = true;
    config = ''
    ${bgtaccess} ${bgterror} {
      rotate 5
      weekly
      create 600 nginx nginx
      postrotate
        ${pkgs.systemd}/bin/systemctl reload nginx
      endscript
    }
    '';
  };

  # 20.09 unharden nginx to write logs
  systemd.services.nginx.serviceConfig.ReadWritePaths = [
    "/var/spool/nginx/logs/"
  ];
  security.acme.certs."download.binaergewitter.de" = {
    dnsProvider = "cloudflare";
    credentialsFile = toString <secrets/lego-binaergewitter>;
    webroot = lib.mkForce null;
  };

  services.nginx = {
    appendHttpConfig = ''
      types {
         audio/ogg oga ogg opus;
      }
    '';
    enable = lib.mkDefault true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    virtualHosts."download.binaergewitter.de" = {
      addSSL = true;
      enableACME = true;
        serverAliases = [ "dl2.binaergewitter.de" ];
        root = "/var/www/binaergewitter";
        extraConfig = ''
          access_log ${bgtaccess} combined;
          error_log ${bgterror} error;
          autoindex on;
        '';
    };
  };
}
