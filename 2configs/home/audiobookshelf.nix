{ pkgs, config, ... }:
let
  dataDir = "/media/silent/db/audiobookshelf";
in
{
  services.audiobookshelf = {
    enable = true;
    host = "0.0.0.0"; # for forwarding from gum
    group = "download";
    openFirewall = true;
    inherit dataDir;
  };

  # move datadir to silent
  systemd.tmpfiles.rules = [
    "d ${dataDir} 0750 ${config.services.audiobookshelf.user} ${config.services.audiobookshelf.group} - -"
  ];
}
