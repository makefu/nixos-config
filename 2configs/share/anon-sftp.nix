{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
{
  services.openssh = {
    allowSFTP = true;
    sftpFlags = [ "-l VERBOSE" ];
    extraConfig = ''
      Match User anonymous
        ForceCommand internal-sftp
        AllowTcpForwarding no
        X11Forwarding no
        PasswordAuthentication no
    '';
  };

  users.users.anonymous = {
    uid = genid "anonymous";
    useDefaultShell = false;
    password = "anonymous";
    home = "/media/anon";
    createHome = true;
  };

}
