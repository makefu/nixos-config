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
  services.opencrow = {
    enable = true;
    piPackage = self.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp;
    skills = {
      nextcloud = "${self.inputs.openclaw-nextcloud}/";
    };
    environment = {
      OPENCROW_SOUL_FILE = "${./soul.md}";
      OPENCROW_MATRIX_HOMESERVER = "https://matrix.cybahn.de";
      # Inference runs on jack's vLLM server (see piModels below), not on a
      # cloud provider; opencrow always passes --provider/--model to omp.
      OPENCROW_PI_PROVIDER = "vllm";
      OPENCROW_PI_MODEL = "vllm/qwen3.8-27b";
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
    # jack.r serves an OpenAI-compatible vLLM endpoint. omp's built-in vllm
    # provider defaults to http://127.0.0.1:8000/v1, so only the base URL needs
    # overriding; auth = none because the server is unauthenticated.
    # models.yml is read by both the service and the `opencrow-pi` wrapper,
    # which does not inherit the service environment.
    piModels = {
      providers.vllm = {
        baseUrl = "http://jack.r:8000/v1";
        auth = "none";
      };
    };

    # Pin the default model role so an omp invocation without --model (e.g. the
    # interactive wrapper) does not fall back to the anthropic default.
    piSettings = {
      modelRoles.default = "vllm/qwen3.8-27b";
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
