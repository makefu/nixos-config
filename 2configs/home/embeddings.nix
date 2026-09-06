# Standalone llama.cpp embedding server (OpenAI-compatible /v1/embeddings).
#
# p0's vLLM exposes no /v1/embeddings (verified 404), so semantic search for
# karakeep (keep.euer) and hister (search.euer) needs its own endpoint. Runs
# on x2 now — omo is too loaded for periodic re-index bursts. Reachable only
# over the euer ULA: the server binds x2's euer address, so no LAN/internet
# exposure regardless of the (euer-zone-only) firewall opening.
#
# Qwen3-Embedding-0.6B (Q8_0, 1024 dims) under CPU inference; verified against
# llama-cpp 10408 (pinned nixpkgs).
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
    url = "https://huggingface.co/Qwen/Qwen3-Embedding-0.6B-GGUF/resolve/main/Qwen3-Embedding-0.6B-Q8_0.gguf";
    hash = "sha256-BlB8e0JohGnE5ymLCh4W3v8GyvKRzwpbJ4wwgknD5Dk=";
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
          --ctx-size 16384
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
    };
  };

  networking.firewall.interfaces.euer.allowedTCPPorts = [ port ];
}
