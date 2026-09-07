# Standalone llama.cpp embedding server (OpenAI-compatible /v1/embeddings).
#
# p0's vLLM exposes no /v1/embeddings (verified 404), so semantic search for
# karakeep (keep.euer) and hister (search.euer) needs its own endpoint. Runs
# on x2 now — omo is too loaded for periodic re-index bursts. Reachable only
# over the euer ULA: the server binds x2's euer address, so no LAN/internet
# exposure regardless of the (euer-zone-only) firewall opening.
#

# Benchmarks (2026-09-07, x2 = i5-3320M 2c AVX1, 400-token probe, single
# request, cold server; RSS = unit VmRSS):
#   BASE  Qwen3-Embedding-0.6B-Q8_0 --ctx-size 16384 (4 slots, default):
#         35 tok/s cold / ~0.6 tok/s effective under karakeep fan-out
#         (4 slots split the ~40 tok/s CPU roofline + queue delay), 3.4 GB
#         RSS, 12.4 GB in production with warm 16k-token KV caches.
#   V1    Qwen3-0.6B-Q8_0 --ctx-size 2048 --parallel 1 -ctk/-ctv q8_0 -fa on:
#         29 tok/s, 1.7 GB RSS. RoPE allows ctx extension, so it was the
#         fallback until llama-server 0.3.0 proved it does NOT clip
#         over-window inputs (400 exceed_context_size_error, truncate:true
#         ignored) — every client must budget inputs itself.
#   V2    bge-small-en-v1.5-Q8_0 (this unit): 794 tok/s, 98 MB RSS;
#         deployed unit: 752 tok/s, MemoryCurrent 152 MB. Winner (20x BASE).
#   V3    all-MiniLM-L6-v2-Q8_0 (not deployed): 1479 tok/s, 86 MB RSS;
#         skipped — V2 already cleared the 10 tok/s target, and V2 is the
#         newer/stronger retrieval model. BERT: same 512-window constraint.
#
# Integration issues found wiring karakeep/hister to this endpoint
# (llama-server 0.3.0, nixpkgs 2026-09-04):
#  1. Over-window input is a hard error, never clipped: 500 "input (N
#     tokens) is too large to process" if N > -ub, 400 exceed_context_size_error
#     if N > slot ctx. BERT position_embd is learned (fixed 512 rows):
#     --ctx-size/-override-kv bert.context_length above 512 only moves the
#     slot cap ("capping" warn) or fails tensor-shape load outright. Larger
#     windows need a RoPE model (Qwen3 + YaRN), not this one.
#  2. Client budgets are mandatory, and token-vs-word estimates are the
#     failure mode: karakeep caps the embedding text at
#     EMBEDDING_CONTEXT_LENGTH *characters* (default 8192! → set 512; safe
#     since 512 chars < 512 BPE tokens). hister chunks by whitespace-word
#     estimate; bge BPE hit ~2.5 tokens per word on URL/code-heavy text
#     (384-word budget → 723-token request), so max_context_length=160.
#     hister treats a rejection as WARN + skip (chunk silently loses
#     semantic coverage), karakeep worker would fail the embedding job.
#  3. Reindex burst stress: karakeep-workers crash-looped once during the
#     full reindex (SqliteError: database is locked + meilisearch submit
#     Timeout); systemd restart recovered it, queue is durable. Expect this
#     again on full reindexes; watch, don't panic.
#  4. Vector stores are dimension-tagged: karakeep validates width against
#     EMBEDDING_DIMENSIONS, hister persists dims per vector — model swap
#     always means full rebuild (karakeep admin reindexAllBookmarks; hister:
#     rm vectors.sqlite3 + `hister reindex`; note `import --skip-existing`
#     will NOT re-embed, only reindex does).
{
  config,
  pkgs,
  lib,
  ...
}:
let
  port = 8091;
  # x2's euer ULA (2configs/wireguard/euer/common.nix). Binding the tunnel
  # address directly means the service only answers on the euer interface.
  bindAddr = "fd42:e1e0::7";
  embeddingModel = pkgs.fetchurl {
    url = "https://huggingface.co/ggml-org/bge-small-en-v1.5-Q8_0-GGUF/resolve/main/bge-small-en-v1.5-q8_0.gguf";
    hash = "sha256-8EbbHcckz09vCgxZF+kigjtz6x0nuPmpwnl/eGaXSAQ=";
  };
in
{
  systemd.services.embeddings = {
    description = "llama.cpp embedding server (karakeep + hister semantic search)";
    wantedBy = [ "multi-user.target" ];
    # Bind target is a systemd-networkd wireguard interface — no per-interface
    # service unit exists; order on the device unit instead, which appears
    # when networkd brings the iface up.
    after = [ "sys-subsystem-net-devices-euer.device" ];
    requires = [ "sys-subsystem-net-devices-euer.device" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.llama-cpp}/bin/llama-server \
          --model ${embeddingModel} \
          --embedding --host ${bindAddr} --port ${toString port} \
          --ctx-size 512 --parallel 1 -b 512 -ub 512
      '';
      # Stateless (model lives in the store) → throwaway uid, no user account.
      DynamicUser = true;
      Restart = "on-failure";
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      PrivateTmp = true;
      # A re-index fan-out must not starve the host: push CPU behind normal
      # traffic and I/O to idle/low weight (idle class applies on bfq, weight
      # on mq-deadline — covered either way).
      Nice = 10;
      CPUWeight = 10;
      IOWeight = 10;
      IOSchedulingClass = "idle";
      # Model is 35 MB; the 512-token single slot leaves RSS ~100 MB. Cap
      # bounds any pathological allocation regardless.
      MemoryMax = "3G";
    };
  };

  networking.firewall.interfaces.euer.allowedTCPPorts = [ port ];
}
