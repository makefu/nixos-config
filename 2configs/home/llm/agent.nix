{ self, pkgs, config, ... }:
let
  hermes = config.services.hermes-agent;
  # nix-store tools the agent invokes from its terminal tool inside the
  # container. The container is Ubuntu; only /nix/store (ro) and stateDir are
  # mounted, so anything not baked into the image or apt-provisioned must be
  # on PATH explicitly. podman create runs as root and the entrypoint only
  # prepends its uv venv, so this PATH (base dirs + venv kept) is the single
  # PATH source; there is deliberately no PATH key in the rendered .env —
  # hermes load_dotenv would clobber the container env.
  agentPath =
    pkgs.lib.makeBinPath [
      pkgs.nodejs
      pkgs.jq
      pkgs.ripgrep
      pkgs.fd
      pkgs.git
      pkgs.curl
      pkgs.wget
      pkgs.python3
      pkgs.w3m
      pkgs.bind
      self.inputs.mics-skills.packages.${pkgs.stdenv.hostPlatform.system}.kagi-search
      (import ./kleinclaw-bin.nix {
        inherit self pkgs;
      })
    ]
    + ":/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/hermes/.venv/bin:/home/hermes/.local/bin";
in
{
  imports = [
    self.inputs.hermes-agent.nixosModules.default
    ./kagi.nix
    ./kleinclaw.nix
  ];

  # Single dotenv block: MATRIX_ACCESS_TOKEN, MATRIX_USER_ID,
  # OPENAI_API_KEY, NEXTCLOUD_TOKEN. The module concatenates it into
  # $HERMES_HOME/.env at activation (runs as root, so default 0400 root is
  # enough). Migrated from opencrow-env with the keys renamed to the
  # MATRIX_*/OPENAI_* names hermes and its skills expect:
  #   clan secrets set --machine omo --user makefu hermes-env
  sops.secrets.hermes-env = { };

  services.hermes-agent = {
    enable = true;

    # Podman (omo already imports 2configs/virtualisation/podman.nix) instead
    # of the native unit: the agent self-modifies (apt/pip/npm) in a
    # persistent writable layer; nix rebuilds only swap the ro /nix/store
    # package behind the current-package symlink.
    container = {
      enable = true;
      backend = "podman";
      # Pulled from Docker Hub on first container create (deploy step).
      image = "ubuntu:24.04";
      extraOptions = [ "--env" "PATH=${agentPath}" ];
      extraVolumes = [
        # Skills: each directory (with SKILL.md) mounts under /skills, the
        # single skills.external_dirs root. The container runs podman as
        # root, so sops' 0400 kagi token is bind-readable; inside, the group
        # bits (group=hermes, same gid via HERMES_GID) gate access.
        "${config.sops.secrets.opencrow-kagi-session-token.path}:/run/secrets/kagi-session-token:ro"
        # openclaw-nextcloud skill (node scripts/nextcloud.js; token +
        # NEXTCLOUD_URL/USER from .env / environment above).
        "${self.inputs.openclaw-nextcloud}:/skills/nextcloud:ro"
      ];
    };

    settings = {
      # inference.p0.contact serves an OpenAI-compatible vLLM endpoint.
      # Custom provider reads its key from OPENAI_API_KEY in .env, so the
      # token never lands in the nix store.
      model = {
        provider = "custom";
        base_url = "https://inference.p0.contact/v1";
        default = "Qwen3.8-27B-FP8";
        # The custom runtime only sends OPENAI_API_KEY to openai.com hosts or
        # one bound via OPENAI_BASE_URL (credential-leak gate); key_env on the
        # model block is the declared rung for a bare custom provider and is
        # read only when base_url matches this endpoint.
        key_env = "OPENAI_API_KEY";
      };
      # vLLM's /v1/models advertises no modality; without this hermes treats
      # the model as text-only and never attaches images.
      model_overrides."custom.Qwen3.8-27B-FP8".supports_vision = true;
      # One session per room (not per participant), matching the old
      # opencrow bot's behaviour.
      group_sessions_per_user = false;
      matrix = {
        require_mention = true;
      };
      skills.external_dirs = [ "/skills" ];
    };

    # Persona. Written to $HERMES_HOME/SOUL.md (host: ${hermes.stateDir}/.hermes).
    hermesHomeFiles."SOUL.md" = ./soul.md;

    environmentFiles = [ config.sops.secrets.hermes-env.path ];

    # Non-secret env. MATRIX_DEVICE_ID must equal the access token's device
    # (HTi5uohXSs): password logins mint a fresh device per start, which
    # would orphan the migrated olm crypto store (BAD_ACCOUNT_KEY) and — via
    # _reset_crypto_store_if_device_changed — silently wipe it.
    environment = {
      MATRIX_HOMESERVER = "https://matrix.cybahn.de";
      MATRIX_ALLOWED_USERS = "@makefu:matrix.cybahn.de";
      MATRIX_DEVICE_ID = "HTi5uohXSs";
      # Fail loudly at startup instead of degrading to blind drops of
      # encrypted events (olm + mautrix.crypto ship in the nix package).
      MATRIX_E2EE_MODE = "required";
      MATRIX_AUTO_THREAD = "true";
      # openclaw-nextcloud skill: non-sensitive config; token from .env.
      NEXTCLOUD_URL = "https://o.euer.krebsco.de";
      NEXTCLOUD_USER = "makefu";
    };
  };

  # Kleinclaw workspace for miniclaw config.yaml + ad drafts.
  systemd.tmpfiles.rules = [
    "d ${hermes.stateDir}/kleinanzeigen 0750 ${hermes.user} ${hermes.group} -"
  ];
}
