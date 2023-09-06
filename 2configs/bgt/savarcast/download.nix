{ config, lib, pkgs, ... }:


let
  stockholm = pkgs.stockholm;
  ident = (builtins.readFile ../auphonic.pub);
  nginxlogs = "/var/log/nginx";
  bgtaccess = "${nginxlogs}/binaergewitter.access.log";
  bgterror =  "${nginxlogs}/binaergewitter.error.log";

  # TODO: only when the data is stored somewhere else
in {
  state = [ bgtaccess bgterror ];

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
    uid = stockholm.lib.genid "auphonic";
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

  services.nginx = {
    enable = lib.mkDefault true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;

    # using letsencrypt certificate without cloudflare
    virtualHosts."podcast.savar.de" = {
      serverAliases = [ "download.binaergewitter.de" "dl.binaergewitter.de" "dl1.binaergewitter.de" "dl2.binaergewitter.de" "binaergewitter.jit.computer" ];
      root = "/var/www/binaergewitter";
      extraConfig = ''
        access_log ${bgtaccess} combined;
        error_log ${bgterror} error;
        autoindex on;
      '';
    };
  };
}
