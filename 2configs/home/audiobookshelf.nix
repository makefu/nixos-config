{ pkgs, lib, config, ... }:
let
  dataDir = "/media/silent/db/audiobookshelf";
  port = 3009;
  domain = "abook.euer";
in
{
  services.audiobookshelf = {
    enable = true;
    host = "0.0.0.0"; # for forwarding from gum
    group = "download";
    openFirewall = true;
    inherit port;
    # upstream dataDir is a name below /var/lib, not a path; the real
    # location is pinned via WorkingDirectory below
  };
  services.nginx = {
    virtualHosts."${domain}" = {
      locations."/" = {
        proxyPass = "http://localhost:${toString port}";
        proxyWebsockets = true;
      };
    };
  };
  # audiobookshelf resolves config/ and metadata/ relative to its cwd, so
  # WorkingDirectory alone decides where the state lives. StateDirectory= only
  # accepts names below /var/lib and would be ignored with a warning, so reset
  # it (empty value clears the list) instead of letting it point elsewhere.
  systemd.services.audiobookshelf.serviceConfig = {
    StateDirectory = lib.mkForce "";
    WorkingDirectory = lib.mkForce dataDir;
  };

  # move datadir to silent
  systemd.tmpfiles.rules = [
    "d ${dataDir} 0750 ${config.services.audiobookshelf.user} ${config.services.audiobookshelf.group} - -"
  ];
}
