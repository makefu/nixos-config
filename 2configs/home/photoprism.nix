{ pkgs, config, lib, ...}:
# Start    | docker-compose up -d
# Stop     | docker-compose stop
# Update   | docker-compose pull
# Logs     | docker-compose logs --tail=25 -f
# Terminal | docker-compose exec photoprism bash
# Help     | docker-compose exec photoprism photoprism help
# Config   | docker-compose exec photoprism photoprism config
# Reset    | docker-compose exec photoprism photoprism reset
# Backup   | docker-compose exec photoprism photoprism backup -a -i
# Restore  | docker-compose exec photoprism photoprism restore -a -i
# Index    | docker-compose exec photoprism photoprism index
# Reindex  | docker-compose exec photoprism photoprism index -a
# Import   | docker-compose exec photoprism photoprism import
# -------------------------------------------------------------------
let
  port = 2347;
  originalsPath = "/media/cryptX/photos";
  internal-ip = "192.168.111.11";
in
{
  services.nginx.virtualHosts."photos" = {
    serverAliases = [
              "photos.lan"
      "foto"  "foto.lan"
      "fotos" "fotos.lan"
    ];

    locations."/".proxyPass = "http://localhost:${toString port}";
    locations."/".proxyWebsockets = true;
    extraConfig = ''
      if ( $server_addr != "${internal-ip}" ) {
        return 403;
      }
    '';
  };
  systemd.services.photoprism.serviceConfig = {
    SupplementaryGroups =  [ "download" "video" "render" ];
    PrivateDevices = lib.mkForce false;
  };
  state = [ config.services.photoprism.storagePath ];
  sops.secrets."omo-photoprism-pw" = {
    group = "video";
    mode = "0750";
  };
  services.photoprism = {
    enable = true;
    inherit port originalsPath;
    passwordFile = config.sops.secrets."omo-photoprism-pw".path;
    storagePath = "/media/silent/db/photoprism";
    settings = {
      PHOTOPRISM_SITE_TITLE = "PhotoPrism";
      PHOTOPRISM_SITE_CAPTION = "FeMi Fotos";
      PHOTOPRISM_SITE_DESCRIPTION = "Unsere Fotos";
      PHOTOPRISM_SITE_AUTHOR = "FeMi";
      PHOTOPRISM_SPONSOR = "true";
      PHOTOPRISM_DEFAULT_LOCALE = "de";
      PHOTOPRISM_READONLY = "false";

      # Hardware encoding
      PHOTOPRISM_FFMPEG_ENCODER = "intel";
      PHOTOPRISM_INIT = "intel";

      PHOTOPRISM_DEBUG = "false";
      PHOTOPRISM_EXPERIMENTAL = "true";
      PHOTOPRISM_DISABLE_SETTINGS = "false";
      PHOTOPRISM_DISABLE_TENSORFLOW = "false";
      PHOTOPRISM_DARKTABLE_PRESETS = "false";
      PHOTOPRISM_DETECT_NSFW = "false";
      PHOTOPRISM_UPLOAD_NSFW = "true";
      PHOTOPRISM_AUTH_MODE = "password";
      PHOTOPRISM_ADMIN_USER = "admin";
      PHOTOPRISM_SITE_URL = "http://192.168.111.11:2342/";  # Public PhotoPrism URL
    };
  };
}
