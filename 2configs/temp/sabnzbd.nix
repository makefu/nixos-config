{pkgs, ...}:
{
  services.sabnzbd.enable = true;
  systemd.services.sabnzbd.environment.SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
}
