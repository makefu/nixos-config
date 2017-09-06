{ config, lib, pkgs, ... }:
# more than just nginx config but not enough to become a module
with import <stockholm/lib>;
let
  hostname = config.krebs.build.host.name;
  bootscript = pkgs.writeTextDir "runit" ''
    set -euf
    cd /root
    mkdir -p .ssh
    echo "${config.krebs.users.makefu.pubkey}" > .ssh/authorized_keys
    chmod 700 -R .ssh
    systemctl restart sshd
  '';
in {

  services.nginx = {
    enable = mkDefault true;
    virtualHosts."boot.euer.krebsco.de" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        root = bootscript;
        index = "runit";
      };
    };
  };
}
