{...}:
{
  services.vsftpd.anonymousUser = true;
  services.vsftpd.enable = true;
  services.vsftpd.chrootlocalUser = true;
  networking.firewall.allowedTCPPorts = [ 21 ];
}
