{ self, pkgs, inputs, config, ... }:
{
  imports = [
    self.inputs.opencrow.nixosModules.default
  ];
  sops.secrets.opencrow-env = {};
  services.opencrow = {
    enable = true;
    piPackage = self.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp;

    environment = {
      #OPENCROW_PI_PROVIDER = "anthropic";
      #OPENCROW_PI_MODEL = "claude-sonnet-4-6";

      OPENCROW_SOUL_FILE = "${./soul.md}";
      OPENCROW_MATRIX_HOMESERVER = "https://matrix.cybahn.de";
    };

    # Extra packages available to the agent inside the container
    extraPackages = with pkgs; [
      curl jq ripgrep fd git python3 w3m dnsutils fd
    ];
    environmentFiles = [
      # matrix config
      # https://github.com/pinpox/opencrow/blob/master/docs/tutorial.md#4-provide-secrets
      config.sops.secrets.opencrow-env.path
    ];
    extensions = {
      memory = true;
      reminders = true;
    };
  };
}
