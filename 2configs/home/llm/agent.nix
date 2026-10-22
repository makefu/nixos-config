{ self, pkgs, config, ... }:
let
  # Same package the CLI client gets (home-manager programs.omp defaults to
  # inputs.omp packages.default), so agent and interactive shell run one omp.
  ompPkg = self.inputs.omp.packages.${pkgs.stdenv.hostPlatform.system}.default;
  # inference.p0.contact serves an OpenAI-compatible vLLM endpoint. omp's
  # built-in vllm provider defaults to http://127.0.0.1:8000/v1, so the base
  # URL needs overriding. models.yml is read by both the service and the
  # `opencrow-pi` wrapper, which does not inherit the service environment —
  # hence the token comes from a `!cmd` read of the bind-mounted secret
  # rather than from an environment variable.
  vllmModels = {
    providers.vllm = {
      baseUrl = "https://inference.p0.contact/v1";
      apiKey = "!cat /run/secrets/opencrow-vllm-api-key";
      # The endpoint happily takes image_url parts, but vLLM's /v1/models
      # advertises no modality, so discovery stamps the model text-only and
      # omp refuses to attach images. Declare the capability by hand.
      modelOverrides."Qwen3.8-27B-FP8".input = [
        "text"
        "image"
      ];
    };
  };
  # Pin the default model role so an omp invocation without --model (e.g. the
  # interactive wrapper) does not fall back to the anthropic default.
  commonPiSettings = {
    modelRoles.default = "vllm/Qwen3.8-27B-FP8";
    modelRoles.vision = "vllm/Qwen3.8-27B-FP8";
    # Nothing local runs inside the container; without this every omp spawn
    # waits on three discovery probes to 127.0.0.1 before it can answer.
    disabledProviders = [
      "ollama"
      "llama.cpp"
      "lm-studio"
    ];
    # omp's builtin memory backend, same as the CLI config
    # (2configs/tools/home-manager/omp.nix), instead of the bundled sediment
    # extension. DB lands in the writable PI_CODING_AGENT_DIR/memories.
    memory.backend = "mnemopi";
    mnemopi.scoping = "per-project";
    # Suppress omp's first-run setup wizard in the non-interactive service.
    setupVersion = 2;
  };
  vllmBind = {
    "/run/secrets/opencrow-vllm-api-key" = {
      hostPath = config.sops.secrets.opencrow-vllm-api-key.path;
      isReadOnly = true;
    };
  };
  extraPackages = with pkgs;[
    jq
    wget
    curl
    ripgrep
    fd
    git
    python3
    w3m
    dnsutils
    nodejs
  ];
in
{
  imports = [
    self.inputs.opencrow.nixosModules.default
    ./kagi.nix
    ./kleinclaw.nix
  ];
  sops.secrets.opencrow-env = {};
  # openclaw-nextcloud skill token. The skill reads NEXTCLOUD_TOKEN from the
  # environment; keep it out of the nix store by sourcing an env-file secret.
  # The secret holds a single line: NEXTCLOUD_TOKEN=<app-password>.
  # Set with: echo -n 'NEXTCLOUD_TOKEN=<token>' | clan secrets set --machine omo --user makefu opencrow-nextcloud-token
  sops.secrets.opencrow-nextcloud-token = {};
  # Bearer token for the inference endpoint. omp resolves it per request via
  # the `!cmd` apiKey in piModels below, so it never lands in the nix store.
  # The container shares the host's uid namespace; 998 is the opencrow user
  # inside it, which does not exist on the host and so cannot be named here.
  sops.secrets.opencrow-vllm-api-key = {
    uid = 998;
    mode = "0400";
  };
  services.opencrow = {
    enable = true;
    piPackage = ompPkg;
    inherit extraPackages;
    skills = {
      nextcloud = "${self.inputs.openclaw-nextcloud}/";
    };
    environment = {
      OPENCROW_SOUL_FILE = "${./soul.md}";
      OPENCROW_MATRIX_HOMESERVER = "https://matrix.cybahn.de";
      # Inference runs on the vLLM endpoint configured in piModels below, not
      # on a cloud provider; opencrow always passes --provider/--model to omp.
      OPENCROW_PI_PROVIDER = "vllm";
      OPENCROW_PI_MODEL = "vllm/Qwen3.8-27B-FP8";
      # openclaw-nextcloud: non-sensitive config. Token comes via env-file secret.
      NEXTCLOUD_URL = "https://o.euer.krebsco.de";
      NEXTCLOUD_USER = "makefu";
    };

    # Extra packages available to the agent inside the container.
    # nodejs: openclaw-nextcloud runs `node scripts/nextcloud.js`.
    environmentFiles = [
      # matrix config
      # https://github.com/pinpox/opencrow/blob/master/docs/tutorial.md#4-provide-secrets
      config.sops.secrets.opencrow-env.path
      # openclaw-nextcloud token (NEXTCLOUD_TOKEN=...)
      config.sops.secrets.opencrow-nextcloud-token.path
    ];
    piModels = vllmModels;

    extraBindMounts = vllmBind;

    piSettings = commonPiSettings;

    extensions = {
      # Bundled sediment memory replaced by omp's mnemopi backend above.
      memory = false;
      reminders = true;
    };
  };

  # nostr identity for the second instance. Env-file form keeps the private
  # key out of the nix store; systemd injects it via EnvironmentFile.
  # The secret holds a single line: OPENCROW_NOSTR_PRIVATE_KEY=<hex>.
  # Set with: echo -n 'OPENCROW_NOSTR_PRIVATE_KEY=<hex>' | clan secrets set --machine omo --user makefu opencrow-nostr-env
  sops.secrets.opencrow-nostr-env = {};
  # Second bot talking nostr through the euer-internal strfry relay
  # (2configs/home/nostr-relay.nix, also on this host). opencrow supports exactly one
  # backend per instance, so the Matrix bot above stays untouched and this
  # one runs in its own container `opencrow-nostr`.
  services.opencrow.instances.nostr = {
    enable = true;
    piPackage = ompPkg;
    inherit extraPackages;
    environment = {
      OPENCROW_BACKEND = "nostr";
      OPENCROW_NOSTR_RELAYS = "ws://nostr.euer";
      OPENCROW_NOSTR_NAME = "opencrow";
      OPENCROW_NOSTR_DISPLAY_NAME = "opencrow";
      OPENCROW_PI_PROVIDER = "vllm";
      OPENCROW_PI_MODEL = "vllm/Qwen3.8-27B-FP8";
      OPENCROW_SOUL_FILE = "${./soul.md}";
      # charts/images upload here (2configs/home/nostr-files.nix on this host)
      OPENCROW_NOSTR_BLOSSOM_SERVERS = "http://nostr-files.euer";
      # openclaw-nextcloud: non-sensitive config. Token comes via env-file secret.
      NEXTCLOUD_URL = "https://o.euer.krebsco.de";
      NEXTCLOUD_USER = "makefu";
    };
    environmentFiles = [
      config.sops.secrets.opencrow-nostr-env.path
      # openclaw-nextcloud token (NEXTCLOUD_TOKEN=...)
      config.sops.secrets.opencrow-nextcloud-token.path
    ];
    piModels = vllmModels;
    piSettings = commonPiSettings;
    extraBindMounts = vllmBind;
    extensions = {
      memory = false;
      reminders = true;
    };
  };

  # The strfry relay (2configs/home/nostr-relay.nix) runs on this host;
  # without this entry the name is unresolvable inside the container. The
  # container shares the host's network namespace, so the omo euer addresses
  # hit the local nginx vhost.
  containers.opencrow-nostr.config.networking.hosts = {
    "fd42:e1e0::2" = [
      "nostr.euer"
      "nostr-files.euer"
    ];
    "172.27.70.2" = [
      "nostr.euer"
      "nostr-files.euer"
    ];
  };
}
