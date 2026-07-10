# Fixed-output derivation: a HuggingFace cache (HF_HOME layout) holding the
# neucodec decoder + its w2v-bert semantic encoder, so the NeuTTS VM test can
# run fully offline. Network is only available here because this is an FOD.
#
# The GGUF backbone is fetched separately as a plain file (see default.nix) and
# passed to the server by path, avoiding llama-cpp's online repo-glob lookup.
{ lib, stdenvNoCC, python3, cacert }:
let
  # hf-transfer: fast, reliable parallel HTTP downloader. Plain LFS is slow and
  # hf-xet stalled on rate limits here.
  hfEnv = python3.withPackages (ps: [ ps.huggingface-hub ps.hf-transfer ]);
in
stdenvNoCC.mkDerivation {
  name = "neutts-model-cache";
  nativeBuildInputs = [ hfEnv cacert ];

  SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
  HF_HUB_DISABLE_TELEMETRY = "1";
  HF_HUB_ENABLE_HF_TRANSFER = "1";

  dontUnpack = true;
  buildPhase = ''
    export HF_HOME=$out
    python3 - <<'PY'
    from huggingface_hub import snapshot_download
    # Fetch exactly the files NeuTTS loads at runtime (matches the locally seeded
    # cache): neucodec decodes from pytorch_model.bin; w2v-bert is the semantic
    # encoder loaded from safetensors.
    repos = {
        "neuphonic/neucodec": ["config.json", "meta.yaml", "pytorch_model.bin"],
        "facebook/w2v-bert-2.0": [
            "config.json", "model.safetensors", "preprocessor_config.json"
        ],
    }
    for repo, allow in repos.items():
        snapshot_download(repo, allow_patterns=allow)
    PY
    # Drop non-deterministic lock/tmp/cache files so the output hash is stable.
    rm -rf "$out"/xet "$out"/hub/.locks "$out"/hub/*/.locks "$out"/.cache || true
    find "$out" -name '*.lock' -delete || true
  '';
  dontInstall = true;
  dontFixup = true;

  outputHashMode = "recursive";
  outputHashAlgo = "sha256";
  outputHash = "sha256-XSoAI/1sXW3N8hvK9WGJoYnX6shO9oBVXIMy/uGE9Lo=";
}
