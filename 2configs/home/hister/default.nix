{
  config,
  lib,
  pkgs,
  ...
}:
let
  port = 4433;
  # Geometry selector shared with the x2 server (embeddings.nix) and
  # karakeep; option declared in 3modules/embedding-profile.nix.
  profile = config.makefu.embeddings.profile;
in
{
  sops.secrets.hister-env = {
    owner = "hister";
    mode = "0400";
  };

  services.hister = {
    enable = true;
    port = port;
    environmentFile = config.sops.secrets.hister-env.path;
    settings = {
      app.log_level = "info";
      server.address = "127.0.0.1:${toString port}";
      # Public URL behind the nginx vhost. wsUrl and hister's CSRF same-host
      # check are derived from it; with the loopback default, token-login
      # POSTs (Origin: http://search.euer) get 403 and the search WebSocket
      # never authenticates.
      server.base_url = "http://search.euer";
      semantic_search = {
        enable = true;
        # Embedding engine shared with karakeep: llama.cpp unit on x2
        # (2configs/home/embeddings.nix). p0/jack vLLM expose no
        # /v1/embeddings (verified 404), so embeddings stay self-hosted.
        embedding_endpoint = "http://x2.euer:8091/v1/embeddings";
      }
      // (
        if profile == "bge-small" then
          {
            embedding_model = "bge-small-en-v1.5";
            dimensions = 384;
            # Server window is 512 tokens and rejects longer inputs outright.
            # Hister chunks by whitespace-word estimate, but bge's BPE tokenizer
            # hits ~2.5 "tokens/word" on URL/code-heavy text plus hister prepends
            # a metadata header per chunk — a 224-word budget still produced
            # 530-token requests. Budget a quarter of the window; chunks that
            # still overflow are skipped by hister (WARN), not fatal.
            max_context_length = 160;
            chunk_overlap = 32;
            # One slot of ctx 512 is shared by every input in a batch
            # request: 8 chunks x ~150 tokens overflow it (HTTP 500, chunks
            # silently skipped). BERT cannot extend ctx (fixed 512 position
            # rows), so batch must stay 1; a single bge request is ms-scale.
            max_embedding_batch_size = 1;
          }
        else
          {
            # qwen3: RoPE model, server ctx 8192; Qwen3 BPE is ~1 token/word on
            # prose, so a 1500-word budget stays under the server's -b 2048
            # input limit even with hister's metadata header.
            embedding_model = "Qwen3-Embedding-0.6B";
            dimensions = 1024;
            max_context_length = 1500;
            chunk_overlap = 100;
            # On x2's 2 cores concurrent Qwen3 requests split the roofline
            # (35 tok/s / N + queue delay); serialize, and keep batches small
            # so one request stays under liteque-style client timeouts.
            max_embedding_concurrency = 1;
            max_embedding_batch_size = 2;
          }
      );
    };
  };

  services.nginx.virtualHosts."search.euer" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
    };
  };

  # Incremental karakeep seeding (import is idempotent via --skip-existing;
  # karakeep URL is positional, both tokens come from the env-file secret:
  # HISTER__APP__ACCESS_TOKEN authenticates the destination via viper env
  # overlay, HISTER_IMPORT_KARAKEEP_TOKEN authenticates the source API).
  systemd.services.hister-karakeep-import = {
    description = "Import karakeep bookmarks into hister";
    after = [ "hister.service" ];
    requires = [ "hister.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "hister";
      Group = "hister";
      EnvironmentFile = config.sops.secrets.hister-env.path;
      ExecStart = ''
        ${lib.getExe pkgs.hister} \
          import karakeep http://keep.euer \
          -u http://127.0.0.1:${toString port} --global --skip-existing
      '';
    };
  };
  systemd.timers.hister-karakeep-import = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "1d";
    };
  };
}
