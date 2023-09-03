{ config, lib, pkgs, ... }:


with pkgs.stockholm.lib;
let
  ident = (builtins.readFile ./auphonic.pub);
  nginxlogs = "/var/log/nginx";
  bgtaccess = "${nginxlogs}/binaergewitter.access.log";
  bgterror =  "${nginxlogs}/binaergewitter.error.log";

  # TODO: only when the data is stored somewhere else
  wwwdir = "/var/www/binaergewitter";
  storedir = "/media/cloud/www/binaergewitter";
in {
  state = [ bgtaccess bgterror ];

  fileSystems."${wwwdir}" = {
    device = storedir;
    options = [ "bind" ];
    depends = [ "/media/cloud" ];
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
    settings.bgt = {
      files = [ bgtaccess bgterror ];
      rotate = 5;
      frequency = "weekly";
      create = "600 nginx nginx";
      postrotate = "${pkgs.systemd}/bin/systemctl reload nginx";
    };
  };

  # 20.09 unharden nginx to write logs
  systemd.services.nginx.serviceConfig.ReadWritePaths = [ nginxlogs ];
  systemd.tmpfiles.rules = [ "d ${nginxlogs} 0700 nginx root - -" ];

  sops.secrets."lego-binaergewitter" = {};
  security.acme.certs."download.binaergewitter.de" = {
    dnsProvider = "cloudflare";
    credentialsFile = config.sops.secrets."lego-binaergewitter".path;
    webroot = lib.mkForce null;
  };

  services.nginx = {
    enable = lib.mkDefault true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    virtualHosts."download.binaergewitter.de" = {
      addSSL = true;
      enableACME = true;
        serverAliases = [ "binaergewitter.jit.computer" "podcast.savar.de" "dl2.binaergewitter.de" ];
        root = "/var/www/binaergewitter";
        extraConfig = ''
          access_log ${bgtaccess} combined;
          error_log ${bgterror} error;
          autoindex on;
        '';
    };
  };
}
