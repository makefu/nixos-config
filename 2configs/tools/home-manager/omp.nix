# OMP (can1357/oh-my-pi) — a pi fork with its own native config tree under
# ~/.omp/agent. Everything pi is configured with here gets mirrored: the
# global context file, the custom p0/jack providers, the extension set and
# (via ai.nix) the mics-skills directory.
{ pkgs, inputs, osConfig ? null, ... }:
let
  extSrc = inputs.pi-agent-extensions;
  yaml = pkgs.formats.yaml { };

  # Same vLLM endpoint as pi/opencode; the bearer token stays out of the store
  # and is read at startup by the `!cat` value syntax (omp runs `!`-prefixed
  # apiKeys as a shell command, like pi's `!cat` in models.json).
  p0BaseUrl = "https://inference.p0.contact/v1";
  p0Model = "Qwen3.8-27B-FP8";
  p0KeyFile =
    if osConfig != null
    then osConfig.sops.secrets.x-p0-inference-api-key.path
    else "/run/secrets/x-p0-inference-api-key";

  # vLLM serves the Qwen chat template: no `developer` role, thinking goes
  # through the template's own field, and pi's effort levels have to be mapped
  # onto the ladder the endpoint actually accepts.
  qwenCompat = {
    supportsDeveloperRole = false;
    thinkingFormat = "qwen-chat-template";
    reasoningEffortMap = {
      minimal = "low";
      medium = "medium";
      xhigh = "high";
    };
  };
in
{
  imports = [ inputs.omp.homeManagerModules.omp ];

  programs.omp = {
    enable = true;
    # pi's settings.json, translated to omp's setting names. `modelRoles.default`
    # carries the thinking level as a `:high` suffix; pi split it into
    # defaultProvider/defaultModel/defaultThinkingLevel.
    settings = {
      modelRoles.default = "p0/${p0Model}:high";
      startup = {
        quiet = true;
        checkUpdate = false;
      };
      memory.backend = "mnemopi";
      mnemopi.scoping = "per-project";
      symbolPreset = "unicode";
      composer.shape = "box";
      theme.dark = "titanium";
      theme.light = "light";
      setupVersion = 2;
      compaction = {
        enabled = true; # default
        idleEnabled = true;
      };
      dev.autoqa = false;
      error.notify = "on";
      display = {
        showTurnTime = true;
        showTokenUsage = true;
        cacheMissMarker = true;
      };
    };
  };

  # User-level context file. Highest-priority native location, so it shadows
  # ~/.claude/CLAUDE.md and ~/.config/opencode/AGENTS.md (both the same file).
  home.file.".omp/agent/AGENTS.md".source = ./.claude/CLAUDE.md;

  # omp migrated ~/.pi/agent/models.json's shape to YAML under `providers:`.
  home.file.".omp/agent/models.yml".source = yaml.generate "omp-models.yml" {
    providers.p0 = {
      baseUrl = p0BaseUrl;
      api = "openai-completions";
      apiKey = "!cat ${p0KeyFile}";
      models = [{
        id = p0Model;
        name = "Qwen 3.8 (27B, p0)";
        reasoning = true;
        # The endpoint advertises no modality; without this omp refuses images.
        input = [ "text" "image" ];
        contextWindow = 262144;
        compat = qwenCompat;
      }];
    };
    providers.jack = {
      # vLLM serves on :8000; the bare host (port 80) has nothing bound.
      baseUrl = "http://jack.r:8000/v1";
      api = "openai-completions";
      apiKey = "dummy";
      models = [{
        id = "qwen3.8-27b";
        name = "Qwen 3.8 (27B, jack)";
        reasoning = true;
        input = [ "text" "image" ];
        contextWindow = 262144;
        compat = qwenCompat;
      }];
    };
  };

  # Same extension set pi loads (see pi-extensions.nix). omp's native
  # auto-discovery in ~/.omp/agent/extensions follows symlinked directories
  # that carry an index.ts, so the multi-file extensions link as directories;
  # the single-file ones link as plain .ts entries. Their
  # @mariozechner/pi-coding-agent imports go through omp's legacy pi shim.
  home.file.".omp/agent/extensions/permission-gate".source = "${extSrc}/permission-gate";
  home.file.".omp/agent/extensions/questionnaire.ts".source = "${extSrc}/questionnaire/index.ts";
}
