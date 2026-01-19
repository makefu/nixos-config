{ config, pkgs, lib, ... }:
let
    port = 3011;
    asset_dir = "/media/silent/db/karakeep/assets";
    meili_data_dir = "/media/silent/db/meili/data";
    meili_snapshot_dir = "/media/silent/db/meili/snapshot";
    meili_dump_dir = "/media/silent/db/meili/dump";
in
{
    systemd.tmpfiles.settings = {
        "10-hoarder-state-dir"."${asset_dir}".d = {
          group = "karakeep";
          mode = "0700";
          user = "karakeep";
        };
        "10-meili-dirs" = {
          "${meili_snapshot_dir}".d.user ="meilisearch";
          "${meili_dump_dir}".d.user ="meilisearch";
          "${meili_data_dir}".d.user ="meilisearch";
        };
    };
    users.groups.meilisearch = { };
    users.users.meilisearch = {
      isSystemUser = true;
      group = "meilisearch";
    };
    systemd.services.meilisearch.serviceConfig = {
        User = "meilisearch";
        Group = "meilisearch";
        DynamicUser = lib.mkForce false;
        # ReadWritePaths is already set by nixos module to datadir,snapshotdir,
    };
    services.meilisearch.settings = {
        db_path = meili_data_dir;
        dump_dir = meili_dump_dir;
        snapshot_dir = meili_snapshot_dir;
    };
    sops.secrets.karakeep-env.owner = "meilisearch";
    services.karakeep = {
        enable = true;
        environmentFile = config.sops.secrets.karakeep-env.path;
        extraEnvironment = {
            # TODO: change DATA_DIR but this seems to be tricky
            PORT = toString port;
            ASSET_DIR = asset_dir;
            #OLLAMA_BASE_URL = "http://x.r:11434";
            #INFERENCE_JOB_TIMEOUT_SEC = "120";
            #INFERENCE_TEXT_MODEL = "olm-3:7b";
            #INFERENCE_TEXT_MODEL = "olm-3:7b";
            #INFERENCE_TEXT_MODEL = "olmo-3:7b-instruct";
            #INFERENCE_TEXT_MODEL = "gemma3:4b";
            #INFERENCE_IMAGE_MODEL = "gemma3:4b";
            #INFERENCE_IMAGE_MODEL = "qwen3-vl:8b";
            # INFERENCE_IMAGE_MODEL = "ministral-3:8b";
            #INFERENCE_IMAGE_MODEL = "ministral-3:3b";
            #EMBEDDING_TEXT_MODEL = "qwen3-embedding:0.6b";
            INFERENCE_ENABLE_AUTO_SUMMARIZATION = "true";
            #INFERENCE_ENABLE_AUTO_SUMMARIZATION = "false";

        };
    };
    # not sure which of the three actually needs access to asset_dir
    systemd.services.karakeep-browser.serviceConfig = {
        ReadWritePaths  = [ asset_dir ];
        Restart = lib.mkForce "always";
        RestartSec = "10s";
    };
    systemd.services.karakeep-workers.serviceConfig = {
        ReadWritePaths  = [ asset_dir ];
        Restart = lib.mkForce "always";
        RestartSec = "10s";
    };
    systemd.services.karakeep-web.serviceConfig = {
        ReadWritePaths  = [ asset_dir ];
        Restart = lib.mkForce "always";
        RestartSec = "10s";
    };
}
