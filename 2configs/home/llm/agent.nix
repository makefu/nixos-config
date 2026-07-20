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
      kagi-search = "${self.inputs.mics-skills}/skills/kagi-search";
    };
    environment = {
      OPENCROW_SOUL_FILE = "${./soul.md}";
      OPENCROW_MATRIX_HOMESERVER = "https://matrix.cybahn.de";
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
    extensions = {
      memory = true;
      reminders = true;
    };
  };
}
