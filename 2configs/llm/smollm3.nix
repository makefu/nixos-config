# SmolLM3-3B chat server (llama.cpp, OpenAI-compatible /v1/chat/completions).
#
# Runs on x (T14, i7-10610U 4c/8t, 30 GB RAM, MX330 without CUDA build —
# pure CPU). Q4_K_M (1.9 GB) fits the memory budget: KV cache for a 8k
# single-slot context adds ~0.5 GB, total RSS stays ~2.5 GB.
#
# Thinking (extended reasoning) is ON via the bundled chat template: the
# GGUF carries SmolLM3's Jinja template with `enable_thinking` defaulting to
# true, and llama-server only evaluates embedded templates with --jinja.
# Per-request toggles work through chat_kwargs:
#   {"chat_format":"chatml","enable_thinking":false}  → no_think mode.
# Without --jinja the server falls back to a plain ChatML template and the
# reasoning header/metadata the model was aligned on is lost — hence the
# flag is load-bearing, not cosmetic.
#
# Sampling mirrors generation_config.json (temp 0.6, top_p 0.95). Context
# 8192 with FlashAttention + q8_0 KV: the model supports 128k (YaRN) but a
# laptop CPU slot bigger than this only burns RAM it cannot reuse.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  port = 8090;
  # x's euer ULA (2configs/wireguard/euer/common.nix). Binding the tunnel
  # address means the API is reachable fleet-wide over euer only — laptop
  # LAN/wifi clients use an ssh tunnel, no internet exposure.
  bindAddr = "fd42:e1e0::3";

  model = pkgs.fetchurl {
    url = "https://huggingface.co/ggml-org/SmolLM3-3B-GGUF/resolve/main/SmolLM3-Q4_K_M.gguf";
    hash = "sha256-gzS4ULe9RiOMFrDFUN8hOPCIm/QzgJAIzBeosFdhhj4=";
  };
in
{
  systemd.services.smollm3 = {
    description = "SmolLM3-3B chat server (llama.cpp, thinking enabled)";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" "sys-subsystem-net-devices-euer.device" ];
    requires = [ "sys-subsystem-net-devices-euer.device" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.llama-cpp}/bin/llama-server \
          --model ${model} \
          --host ${bindAddr} --port ${toString port} \
          --jinja \
          --ctx-size 8192 --parallel 1 \
          -fa on -ctk q8_0 -ctv q8_0 \
          --temp 0.6 --top-p 0.95 \
          --no-warmup
      '';
      # Stateless (model in store) → throwaway uid, same hardening as
      # 2configs/home/embeddings.nix.
      DynamicUser = true;
      Restart = "on-failure";
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      PrivateTmp = true;
      # Chat is interactive: keep it ahead of background embed builds but
      # behind the session (Nice 5, full weight — a token stream starved
      # mid-generation stalls the user, it buys nothing back).
      Nice = 5;
      CPUWeight = 100;
      IOWeight = 10;
      IOSchedulingClass = "idle";
      MemoryMax = "6G";
    };
  };

  networking.firewall.interfaces.euer.allowedTCPPorts = [ port ];
}
