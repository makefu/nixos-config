{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
let
  ident = (builtins.readFile ./auphonic.pub);
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
  services.nginx = {
    enable = lib.mkDefault true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    virtualHosts."download.binaergewitter.de" = {
        serverAliases = [ "dl2.binaergewitter.de" ];
        root = "/var/www/binaergewitter";
        extraConfig = ''
          access_log /var/spool/nginx/logs/binaergewitter.access.log combined;
          error_log /var/spool/nginx/logs/binaergewitter.error.log error;
          autoindex on;
        '';
    };
  };
}
