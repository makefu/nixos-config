{ config, lib, pkgs, ... }:
let
  port = 4433;
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
      semantic_search = {
        enable = true;
        # Same embedding engine karakeep uses (karakeep-embeddings llama.cpp
        # unit). p0/jack vLLM expose no /v1/embeddings (verified 404), so
        # embeddings stay local.
        embedding_endpoint = "http://127.0.0.1:8091/v1/embeddings";
        embedding_model = "Qwen3-Embedding-0.6B";
        dimensions = 1024;
      };
    };
  };

  services.nginx.virtualHosts."search.euer" = {
    locations."/" = { proxyPass = "http://127.0.0.1:${toString port}"; };
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
    timerConfig = { OnBootSec = "5m"; OnUnitActiveSec = "1d"; };
  };
}
