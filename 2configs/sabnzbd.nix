{ pkgs, config, ... }:

with config.krebs.lib;
let
  web-port = 8080;
in {
  services.sabnzbd.enable = true;
  services.sabnzbd.group = "download";
  systemd.services.sabnzbd.environment.SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

  users.users.sabnzbd.group = mkForce "download";

  networking.firewall.extraCommands = ''
    iptables -A INPUT -i retiolum -p tcp --dport ${toString web-port} -j ACCEPT
  '';
}
