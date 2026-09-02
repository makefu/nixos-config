{ self, pkgs, config, ... }:
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
    piPackage = self.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp;
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
    extraPackages = with pkgs; [
      curl jq ripgrep fd git python3 w3m dnsutils fd nodejs
    ];
    environmentFiles = [
      # matrix config
      # https://github.com/pinpox/opencrow/blob/master/docs/tutorial.md#4-provide-secrets
      config.sops.secrets.opencrow-env.path
      # openclaw-nextcloud token (NEXTCLOUD_TOKEN=...)
      config.sops.secrets.opencrow-nextcloud-token.path
    ];
    # inference.p0.contact serves an OpenAI-compatible vLLM endpoint. omp's
    # built-in vllm provider defaults to http://127.0.0.1:8000/v1, so the base
    # URL needs overriding. models.yml is read by both the service and the
    # `opencrow-pi` wrapper, which does not inherit the service environment —
    # hence the token comes from a `!cmd` read of the bind-mounted secret
    # rather than from an environment variable.
    piModels = {
      providers.vllm = {
        baseUrl = "https://inference.p0.contact/v1";
        apiKey = "!cat /run/secrets/opencrow-vllm-api-key";
      };
    };

    extraBindMounts."/run/secrets/opencrow-vllm-api-key" = {
      hostPath = config.sops.secrets.opencrow-vllm-api-key.path;
      isReadOnly = true;
    };

    # Pin the default model role so an omp invocation without --model (e.g. the
    # interactive wrapper) does not fall back to the anthropic default.
    piSettings = {
      modelRoles.default = "vllm/Qwen3.8-27B-FP8";
      # Nothing local runs inside the container; without this every omp spawn
      # waits on three discovery probes to 127.0.0.1 before it can answer.
      disabledProviders = [
        "ollama"
        "llama.cpp"
        "lm-studio"
      ];
      # Suppress omp's first-run setup wizard in the non-interactive service.
      setupVersion = 2;
    };

    extensions = {
      memory = true;
      reminders = true;
    };
  };
}
