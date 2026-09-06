{ pkgs, inputs, lib, osConfig ? null, ... }:
let
  aiTools = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  micsSkillsPkgs = inputs.mics-skills.packages.${pkgs.stdenv.hostPlatform.system};

  p0BaseUrl = "https://inference.p0.contact/v1";
  p0Model = "Qwen3.8-27B-FP8";
  p0KeyFile =
    if osConfig != null
    then osConfig.sops.secrets.x-p0-inference-api-key.path
    else "/run/secrets/x-p0-inference-api-key";
in
{

    imports = [
      inputs.mics-skills.homeModules.default
      ./omp.nix
    ];

    # Default prompt: mirror the Claude Code CLAUDE.md ruleset into pi and
    # opencode via each tool's official global-instructions file, so all
    # three agents share one prompt. Neither tool writes these files, so
    # store symlinks are safe.
    # - pi: ~/.pi/agent/AGENTS.md is the global context file; SYSTEM.md /
    #   APPEND_SYSTEM.md would replace/append the system prompt itself.
    #   Keep AGENTS.md so pi's own default prompt stays intact.
    # - opencode: ~/.config/opencode/AGENTS.md is auto-loaded for every
    #   session (global rules). The alternative knobs — `instructions` in
    #   opencode.json (extra files) and agent.build.prompt (full replace) —
    #   are deliberately unused to avoid double-loading the ruleset.
    home.file.".pi/agent/AGENTS.md".source = ./.claude/CLAUDE.md;
    home.file.".config/opencode/AGENTS.md".source = ./.claude/CLAUDE.md;

    #home.file.".config/workmux/config.yaml".source = ./.config/workmux/config.yaml;

    home.file.".config/opencode/opencode.json".text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      # first use, so the model list is declared here instead of discovered.
      provider.p0 = {
        npm = "@ai-sdk/openai-compatible";
        name = "p0 inference";
        options = {
          baseURL = p0BaseUrl;
          apiKey = "{file:${p0KeyFile}}";
        };
        models.${p0Model}.name = "Qwen 3.8 (27B, p0)";
      };
      model = "p0/${p0Model}";
    };

    # pi reads ~/.pi/agent/models.json and never writes it, so a nix store
    # symlink is safe here (settings.json below is not — pi rewrites it).
    home.file.".pi/agent/models.json".text = builtins.toJSON {
      providers.p0 = {
        baseUrl = p0BaseUrl;
        api = "openai-completions";
        apiKey = "!cat ${p0KeyFile}";
        models = [{
          id = p0Model;
          contextWindow = 262144;
          name = "Qwen 3.8 (27B, p0)";
          reasoning = true;
          # vLLM's /v1/models advertises no modality; declare image input by
          # hand or pi refuses to attach images.
          input = [ "text" "image" ];
          compat = {
            supportsDeveloperRole = false;
            thinkingFormat = "qwen-chat-template";
            reasoningEffortMap = {
              "minimal" = "low";
              "medium" = "medium";
              "xhigh"   = "high";
            };
          };
        }];
      };
      providers.jack = {
        # vLLM serves on :8000; the bare host (port 80) has nothing bound.
        baseUrl = "http://jack.r:8000/v1";
        api = "openai-completions";
        apiKey = "dummy";
        models = [{
          id = "qwen3.8-27b";
          contextWindow = 262144;
          name = "Qwen 3.8 (27B, jack)";
          reasoning = true;
          input = [ "text" "image" ];
          compat = {
            supportsDeveloperRole = false;
            thinkingFormat = "qwen-chat-template";
            reasoningEffortMap = {
              "minimal" = "low";
              "medium" = "medium";
              "xhigh"   = "high";
            };
          };
        }];
      };
    };

    programs.mics-skills = {
      enable = true;
      package = micsSkillsPkgs;
      skillDirs = [
        ".claude/skills"
        ".opencode/skills"
        ".pi/agent/skills"
        ".omp/agent/skills"
      ];
      skills = [
        #"browser-cli"
        #"calendar-cli"
        #"context7-cli"
        #"db-cli"
        #"gmaps-cli"
        "kagi-search"
        #"n8n-cli"
        "pexpect-cli"
        "screenshot-cli"
        "queue"
      ];
    };
    home.packages= with aiTools;[
      workmux
      #claude-code
      #ccstatusline
      pi
      pkgs.opencode
      pkgs.ha-mcp
      #pkgs.claude-monitor
    ];
}
