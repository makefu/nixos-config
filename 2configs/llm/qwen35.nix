# Qwen3.5-4B chat server (llama.cpp, OpenAI-compatible /v1/chat/completions).
#
# Runs on x (T14, i7-10610U 4c/8t, 30 GB RAM, MX330 without CUDA build —
# pure CPU). Replaces nothing; coexists with smollm3 (port 8090).
#
# Why the MTP GGUF: Qwen3.5 ships a nextn/MTP draft head (1 extra block,
# qwen35.nextn_predict_layers = 1). The MTP-GGUF repo carries those tensors;
# the plain GGUF drops them. On this CPU, --spec-type draft-mtp with
# --spec-draft-n-max 3 measured 6.9 t/s vs 6.7 t/s plain (temp 0, 250-token
# completions) — roughly break-even, because draft+verify costs CPU compute
# while the bottleneck here is memory bandwidth. It is kept anyway: n=3
# never lost, the acceptance is lossless (verified by the target), and
# larger/batched loads benefit more. Larger n (4..8) lost badly (5.6 →
# 3.8 t/s): verification of K speculative tokens costs a K+1-token batch
# forward per step, which dominates on a 4-core CPU.
#
# Measured decode (llama-server 0.3.0 / c1d0e7a, temp 0, 250 tokens, median):
#   plain Q4_K_M, -fa on                    6.7 t/s
#   plain Q4_K_M, -fa off                   6.2 t/s
#   plain Q4_K_M, --threads 4               6.6 t/s   (no win vs auto=8)
#   plain Q4_K_M, -ctk/-ctv q8_0            7.1 t/s   ← KV quant wins
#   MTP n=3                                 6.9 t/s (acceptance 0.56, len 2.7)
#   MTP n=4/5/6/8                           5.6/4.8/4.3/3.8 t/s
# So: FlashAttention + q8_0 KV are the real levers; MTP n=3 is free option.
#
# Memory: model 2.8 GB + q8_0 KV for 16k ctx (4 KV heads × 32 layers,
# key/value len 256) stays ~1 GB below the 8G cap even with the MTP draft
# context. Qwen3.5 is hybrid (Gated DeltaNet + attention): the recurrent
# state is per-slot and dominates KV size more than the attention KV.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  port = 8092;
  # x's euer ULA (2configs/wireguard/euer/common.nix) — same binding policy
  # as 2configs/llm/smollm3.nix: fleet-internal over euer only.
  bindAddr = "fd42:e1e0::3";

  model = pkgs.fetchurl {
    url = "https://huggingface.co/unsloth/Qwen3.5-4B-MTP-GGUF/resolve/main/Qwen3.5-4B-Q4_K_M.gguf";
    hash = "sha256-OHQgkkHJo5fi9izT9w+A/S378N/MtoOEFr20inFOhjA=";
  };
in
{
  systemd.services.qwen35 = {
    description = "Qwen3.5-4B chat server (llama.cpp, MTP spec-dec, thinking on)";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" "sys-subsystem-net-devices-euer.device" ];
    requires = [ "sys-subsystem-net-devices-euer.device" ];
    serviceConfig = {
      # Thinking ON by default: the embedded Qwen3.5 chat template gates the
      # think block on enable_thinking and defaults it OFF, so it is forced
      # on via --chat-template-kwargs. A per-request "chat_template_kwargs":
      # {"enable_thinking": false} still toggles it off.
      #
      # Sampling mirrors the official Qwen3.5 recommendation for thinking /
      # general tasks: temp 1.0, top_p 0.95, top_k 20, min_p 0.0,
      # presence_penalty 1.5.
      ExecStart = ''
        ${pkgs.llama-cpp}/bin/llama-server \
          --model ${model} \
          --host localhost --port ${toString port} \
          --jinja \
          --ctx-size 16384 --parallel 1 \
          -fa on -ctk q8_0 -ctv q8_0 \
          --spec-type draft-mtp --spec-draft-n-max 3 \
          --chat-template-kwargs '{"enable_thinking": true}' \
          --temp 1.0 --top-k 20 --top-p 0.95 --min-p 0.0 --presence-penalty 1.5 \
          --no-warmup
      '';
      # Stateless (model in store) → throwaway uid, same hardening as
      # 2configs/llm/smollm3.nix.
      DynamicUser = true;
      Restart = "on-failure";
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      PrivateTmp = true;
      Nice = 5;
      CPUWeight = 100;
      IOWeight = 10;
      IOSchedulingClass = "idle";
      MemoryMax = "8G";
    };
  };

  networking.firewall.interfaces.euer.allowedTCPPorts = [ port ];
}
