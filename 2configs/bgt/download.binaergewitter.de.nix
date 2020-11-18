{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
let
  ident = (builtins.readFile ./auphonic.pub);
  bgtaccess = "/var/spool/nginx/logs/binaergewitter.access.log";
  bgterror = "/var/spool/nginx/logs/binaergewitter.error.log";
in {
  services.openssh = {
    allowSFTP = true;
    sftpFlags = [ "-l VERBOSE" ];
    extraConfig = ''
      Match User auphonic
        ForceCommand internal-sftp
        AllowTcpForwarding no
        X11Forwarding no
        PasswordAuthentication no
    '';
  };
  users.users.auphonic = {
    uid = genid "auphonic";
    group = "nginx";
    useDefaultShell = true;
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
        serverAliases = [ "dl2.binaergewitter.de" ];
        root = "/var/www/binaergewitter";
        extraConfig = ''
          access_log ${bgtaccess} combined;
          error_log ${bgterror} error;
          autoindex on;
        '';
    };
  };
  environment.etc."netdata/python.d/web_log.conf".text = ''
    nginx_log3:
      name: 'nginx'
      path: '/var/spool/nginx/logs/access.log'
    nginx_log4:
      name: 'bgt'
      path: '${bgtaccess}'
  '';

  users.users.netdata.extraGroups = [ "nginx" ];

}
