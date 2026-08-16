{ config, lib, pkgs, ... }:
# more than just nginx config but not enough to become a module
with lib;
let
  hostname = config.clan.core.settings.machine.name;
  bootscript = pkgs.writeTextDir "runit" ''
    set -euf
    cd /root
    mkdir -p .ssh
    echo "${concatStringsSep "\n" config.krebs.users.makefu.pubkeys}" > .ssh/authorized_keys
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
