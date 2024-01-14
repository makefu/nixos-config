{config, ... }:
{
  sops.secrets."omo-paperless-admin-pw".owner = "paperless";
  services.paperless = {
    enable = true;
    passwordFile config.sops.secrets."omo-paperless-admin-pw".path;
    settings = {
      PAPERLESS_DBHOST = "/run/postgresql";
      PAPERLESS_REDIS = "redis://localhost:6379";
      PAPERLESS_TIKA_ENABLED = "1";
      PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://localhost:30300";
      PAPERLESS_TIKA_ENDPOINT = "http://localhost:9998";
      PAPERLESS_OCR_LANGUAGES = "de";
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "paperless" ];
    ensureUsers = [
      { name = config.services.paperless.user;
        ensureDBOwnership = true;
      }
    ];
  };

  services.redis.enable = true;

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
