{config, lib, ... }:
let
  paperuser = config.services.paperless.user;
in
{
  sops.secrets."paperless-admin-pw".owner = "paperless";
  services.paperless = {
    enable = true;
    passwordFile = config.sops.secrets."paperless-admin-pw".path;
    address = "0";
    # consumptionDir = "/media/cloud/nextcloud-data/makefu/files/SwiftScan";
    settings = {
      PAPERLESS_DBHOST = "/run/postgresql";
      #PAPERLESS_REDIS = "redis://127.0.0.1:6379";
      PAPERLESS_TIKA_ENABLED = "1";
      PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://127.0.0.1:30300";
      PAPERLESS_TIKA_ENDPOINT = "http://127.0.0.1:9998";
      PAPERLESS_OCR_LANGUAGES = "deu+eng";
      PAPERLESS_FILENAME_FORMAT = "{created}_{title}";
      PAPERLESS_OCR_SKIP_ARCHIVE_FILE = "always";
      # PAPERLESS_OCR_MODE="redo";
      #USE_X_FORWARD_HOST= true;
      #USE_X_FORWARD_PORT = true;
      #PAPERLESS_URL = "http://work.euer.krebsco.de";
      #PAPERLESS_URL = "http://omo.r";
    };
  };
  users.users.${paperuser}.extraGroups = [ "download"]; # access nextcloud

  services.nginx = {
    enable = lib.mkDefault true;
    virtualHosts."paper.omo.r" = {
      serverAliases = [ "work.euer.krebsco.de" "paper.euer.krebsco.de" "paper.makefu.r" ];
      locations."/" = {
        proxyPass = "http://localhost:28981";
      };
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "paperless" ];
    ensureUsers = [
      { name = paperuser;
        ensureDBOwnership = true;
      }
    ];
  };

  # services.redis.enable = true;

  virtualisation.oci-containers.containers = {
    gotenberg = {
        image = "docker.io/gotenberg/gotenberg:7.4";
        extraOptions = [ "--network=host" ];
        entrypoint = "gotenberg";
        cmd = [ "--api-port=30300" "--chromium-disable-routes=true" ];
      };
      tika = {
        image = "ghcr.io/paperless-ngx/tika:2.5.0-full";
        extraOptions = [ "--network=host" ];
      };
  };
}
