{ config, lib, pkgs, ... }:

let
  ident = (toString <secrets>) + "/mirrorsync.gum.id_ed25519";
in {
  systemd.services.mirrorsync = {
    startAt = "08:00:00";
    path = with pkgs; [ rsync openssh ];
    script = ''rsync -av -e "ssh -i ${ident}" mirrorsync@159.69.132.234:/var/www/html/ /var/www/binaergewitter'';
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
