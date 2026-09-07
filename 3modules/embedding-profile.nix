# Selects the embedding model geometry shared by the x2 llama-server unit
# (2configs/home/embeddings.nix) and the omo clients (karakeep, hister).
# Both sides must agree on dimensions + window, so the switch is one option
# set on both machines (machines/{x2,omo}/config.nix), not per-client
# literals that can drift.
#
#   bge-small (default): current production winner, 384 dims, 512 window.
#   qwen3:               1024 dims, 8192 window, serialized single-stream
#                        server. Measured end-to-end 2026-09-07: rebuilds
#                        take days on x2 (see embeddings.nix benchmark
#                        table); bge-small remains the production default.
{ lib, ... }:
{
  options.makefu.embeddings.profile = lib.mkOption {
    type = lib.types.enum [
      "bge-small"
      "qwen3"
    ];
    default = "bge-small";
    description = "Embedding model profile shared by server and clients.";
  };

  config.makefu.embeddings.profile = lib.mkDefault "bge-small";
}
