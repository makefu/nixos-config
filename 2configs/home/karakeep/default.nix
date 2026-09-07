{
  config,
  pkgs,
  lib,
  ...
}:
let
  port = 3011;
  asset_dir = "/media/silent/db/karakeep/assets";
  meili_data_dir = "/media/silent/db/meili/data";
  meili_snapshot_dir = "/media/silent/db/meili/snapshot";
  meili_dump_dir = "/media/silent/db/meili/dump";
  # Embeddings moved to x2 (2configs/home/embeddings.nix) — p0's vLLM has
  # no /v1/embeddings, so semantic search needs its own llama.cpp endpoint,
  # and it no longer runs next to karakeep to keep re-index bursts off omo.
  # Embedding geometry selector; server side lives in embeddings.nix, the
  # option in 3modules/embedding-profile.nix (clan var meta.embedding-profile).
  profile = config.makefu.embeddings.profile;
in
{
  services.nginx.virtualHosts."keep.euer" = {
    locations."/" = {
      proxyPass = "http://localhost:${toString port}";
      proxyWebsockets = true;
    };
  };
  networking.firewall.allowedTCPPorts = [ port ];
  systemd.tmpfiles.settings = {
    "10-hoarder-state-dir"."${asset_dir}".d = {
      group = "karakeep";
      mode = "0700";
      user = "karakeep";
    };
    "10-meili-dirs" = {
      "${meili_snapshot_dir}".d.user = "meilisearch";
      "${meili_dump_dir}".d.user = "meilisearch";
      "${meili_data_dir}".d.user = "meilisearch";
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
    max_indexing_memory = "1Gb";
    experimental_reduce_indexing_memory_usage = true;
    max_indexing_threads = 2;
  };
  sops.secrets.karakeep-env = {
    owner = "karakeep";
    restartUnits = [
      "karakeep-web.service"
      "karakeep-workers.service"
    ];
  };
  services.karakeep = {
    enable = true;
    environmentFile = config.sops.secrets.karakeep-env.path;
    extraEnvironment = {
      # TODO: change DATA_DIR but this seems to be tricky
      PORT = toString port;
      ASSET_DIR = asset_dir;

      # Same inference engine omp uses (2configs/tools/home-manager/omp.nix
      # provider "p0"): OpenAI-compatible vLLM on inference.p0.contact.
      # The bearer token is not here; it lives in the karakeep-env
      # environment-file secret (OPENAI_API_KEY=).
      OPENAI_BASE_URL = "https://inference.p0.contact/v1";
      INFERENCE_TEXT_MODEL = "Qwen3.8-27B-FP8";
      # The endpoint takes image_url parts (same model omp uses for vision).
      INFERENCE_IMAGE_MODEL = "Qwen3.8-27B-FP8";
      # Client-side content budget for tagging/summarization prompts, not
      # sent to the API: karakeep truncates bookmark text to
      # contextLength - prompt-template tokens (tiktoken count). p0's
      # vLLM enforces prompt + max_tokens <= 262144 (same window omp uses
      # as contextWindow), and karakeep always requests
      # INFERENCE_MAX_OUTPUT_TOKENS (default 2048), so the budget is the
      # window minus that output reserve; 262144 here would 400 on big
      # pages.
      INFERENCE_CONTEXT_LENGTH = "260096";
      INFERENCE_JOB_TIMEOUT_SEC = "120";
      # The Qwen model thinks by default; medium keeps reasoning on for
      # tagging/summarization quality without max-budget thinking. p0
      # honours the flag (reasoning_tokens scale with effort: 0/none,
      # 14/low observed).
      OPENAI_REASONING_EFFORT = "medium";

      # AI chat over the bookmark collection (chat model = text model).
      CHAT_ENABLED = "true";
      # Image-asset text extraction via the vision model instead of
      # tesseract; p0 accepts image_url parts (omp drives vision on it).
      OCR_USE_LLM = "true";

      # Semantic search: embeddings served by the llama.cpp unit on x2
      # (2configs/home/embeddings.nix, x2.euer = fd42:e1e0::7), vectors
      # stored in the existing meilisearch (needs >= 1.13 for the stable
      # embeddings API; fleet pins 1.53). Auto-indexing is off by default
      # once OPENAI_BASE_URL is set, so switch it on.
      # Geometry follows the profile selector (3modules/embedding-profile.nix);
      # the server rejects over-window inputs outright, so the text budget
      # (in CHARACTERS here) must stay under the server's real token limit.
      # EMBEDDING_NUM_WORKERS stays default here; the qwen3 branch below
      # serializes it (Qwen3 on x2's 2 cores only holds its roofline when
      # one stream runs, see embeddings.nix header).
      EMBEDDING_OPENAI_BASE_URL = "http://x2.euer:8091/v1";
      EMBEDDING_ENABLE_AUTO_INDEXING = "true";
      SEMANTIC_SEARCH_ENABLED = "true";
      INFERENCE_ENABLE_AUTO_SUMMARIZATION = "true";
    }
    // (
      if profile == "bge-small" then
        {
          EMBEDDING_TEXT_MODEL = "bge-small-en-v1.5";
          EMBEDDING_DIMENSIONS = "384";
          EMBEDDING_CONTEXT_LENGTH = "512";
        }
      else
        {
          # qwen3: budget chars <= the server's -ub/n-batch input limit (2048).
          EMBEDDING_TEXT_MODEL = "Qwen3-Embedding-0.6B";
          EMBEDDING_DIMENSIONS = "1024";
          EMBEDDING_CONTEXT_LENGTH = "2048";
          EMBEDDING_NUM_WORKERS = "1";
        }
    );
  };
  # not sure which of the three actually needs access to asset_dir
  systemd.services.karakeep-browser.serviceConfig = {
    ReadWritePaths = [ asset_dir ];
    Restart = lib.mkForce "always";
    RestartSec = "10s";
  };
  systemd.services.karakeep-workers.serviceConfig = {
    ReadWritePaths = [ asset_dir ];
    Restart = lib.mkForce "always";
    RestartSec = "10s";
  };
  systemd.services.karakeep-web.serviceConfig = {
    ReadWritePaths = [ asset_dir ];
    Restart = lib.mkForce "always";
    RestartSec = "10s";
  };
}
