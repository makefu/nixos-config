{ config, ... }:

{
  users.users = {
    share = {
      uid = 9002;
      home = "/var/empty";
      openssh.authorizedKeys.keys = [ config.krebs.users.makefu.pubkey ];
    };
  };
  # we will use internal-sftp to make uncomplicated Chroot work
  services.openssh.extraConfig = ''
    Match User share
      ChrootDirectory /media
      ForceCommand internal-sftp
      AllowTcpForwarding no
      PermitTunnel no
      X11Forwarding no
    Match All
  '';
}
