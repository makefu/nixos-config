{ pkgs, inputs, ... }:
let
  aiTools = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  micsSkillsPkgs = inputs.mics-skills.packages.${pkgs.stdenv.hostPlatform.system};
  caveman = inputs.caveman;
  # caveman ships its opencode plugin under src/plugins/opencode and the
  # plugin's require() bridge expects caveman-config to live next to plugin.js
  # as a .cjs sibling (the plugin dir is "type": "module").
  cavemanOpencode = "${caveman}/src/plugins/opencode";

  # caveman for Claude Code. The marketplace install path (claude plugin
  # marketplace add JuliusBrussee/caveman) writes mutable state into
  # ~/.claude/plugins/known_marketplaces.json which fights nix-managed
  # symlinks. Instead, wire each piece directly: hooks via settings.json,
  # plus per-file links for commands, agents and skills.
  node = "${pkgs.nodejs}/bin/node";
  cavemanCmd = name: hook: {
    hooks = [{
      type = "command";
      command = ''${node} "${caveman}/src/hooks/${hook}"'';
      timeout = 5;
      statusMessage = "caveman: ${name}";
    }];
  };

  baseSettings = builtins.fromJSON (builtins.readFile ./.claude/settings.json);
  mergedSettings = baseSettings // {
    hooks = baseSettings.hooks // {
      SessionStart =
        (baseSettings.hooks.SessionStart or [])
        ++ [ (cavemanCmd "activate" "caveman-activate.js") ];
      UserPromptSubmit =
        (baseSettings.hooks.UserPromptSubmit or [])
        ++ [ (cavemanCmd "mode-tracker" "caveman-mode-tracker.js") ];
    };
  };
in
{

    imports = [
      inputs.mics-skills.homeModules.default
    ];
    services.pueue.enable = true;
    home.file.".claude/CLAUDE.md".source = ./.claude/CLAUDE.md;
    home.file.".claude/settings.json".text = builtins.toJSON mergedSettings;

    # caveman for Claude Code: slash commands, cavecrew subagents, skills.
    home.file.".claude/commands/caveman.toml".source =
      "${caveman}/commands/caveman.toml";
    home.file.".claude/commands/caveman-commit.toml".source =
      "${caveman}/commands/caveman-commit.toml";
    home.file.".claude/commands/caveman-init.toml".source =
      "${caveman}/commands/caveman-init.toml";
    home.file.".claude/commands/caveman-review.toml".source =
      "${caveman}/commands/caveman-review.toml";
    home.file.".claude/agents/cavecrew-builder.md".source =
      "${caveman}/agents/cavecrew-builder.md";
    home.file.".claude/agents/cavecrew-investigator.md".source =
      "${caveman}/agents/cavecrew-investigator.md";
    home.file.".claude/agents/cavecrew-reviewer.md".source =
      "${caveman}/agents/cavecrew-reviewer.md";
    home.file.".claude/skills/caveman".source =
      "${caveman}/skills/caveman";
    home.file.".claude/skills/caveman-commit".source =
      "${caveman}/skills/caveman-commit";
    home.file.".claude/skills/caveman-compress".source =
      "${caveman}/skills/caveman-compress";
    home.file.".claude/skills/caveman-help".source =
      "${caveman}/skills/caveman-help";
    home.file.".claude/skills/caveman-review".source =
      "${caveman}/skills/caveman-review";
    home.file.".claude/skills/caveman-stats".source =
      "${caveman}/skills/caveman-stats";
    home.file.".claude/skills/cavecrew".source =
      "${caveman}/skills/cavecrew";

    home.file.".claude/skills/coordinator".source =
      "${aiTools.workmux}/share/workmux/skills/coordinator";
    home.file.".claude/skills/merge".source =
      "${aiTools.workmux}/share/workmux/skills/merge";
    home.file.".claude/skills/rebase".source =
      "${aiTools.workmux}/share/workmux/skills/rebase";
    home.file.".claude/skills/worktree".source =
      "${aiTools.workmux}/share/workmux/skills/worktree";
    home.file.".claude/skills/workmux".source =
      "${aiTools.workmux}/share/workmux/skills/workmux";

    home.file.".config/workmux/config.yaml".source = ./.config/workmux/config.yaml;

    # opencode + caveman plugin. Mirrors the layout produced by
    # `node bin/install.js --only opencode` from the caveman repo.
    home.file.".config/opencode/plugins/caveman/plugin.js".source =
      "${cavemanOpencode}/plugin.js";
    home.file.".config/opencode/plugins/caveman/package.json".source =
      "${cavemanOpencode}/package.json";
    home.file.".config/opencode/plugins/caveman/caveman-config.cjs".source =
      "${caveman}/src/hooks/caveman-config.js";
    home.file.".config/opencode/commands/caveman.md".source =
      "${cavemanOpencode}/commands/caveman.md";
    home.file.".config/opencode/commands/caveman-commit.md".source =
      "${cavemanOpencode}/commands/caveman-commit.md";
    home.file.".config/opencode/commands/caveman-help.md".source =
      "${cavemanOpencode}/commands/caveman-help.md";
    home.file.".config/opencode/commands/caveman-review.md".source =
      "${cavemanOpencode}/commands/caveman-review.md";
    home.file.".config/opencode/commands/caveman-stats.md".source =
      "${cavemanOpencode}/commands/caveman-stats.md";
    home.file.".config/opencode/opencode.json".text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      plugin = [ "./plugins/caveman/plugin.js" ];
    };

    programs.mics-skills = {
      enable = true;
      package = micsSkillsPkgs;
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
      ];
    };
    home.packages= with aiTools;[
      workmux
      claude-code
      ccstatusline
      pi
      pkgs.pueue
      pkgs.opencode
      pkgs.ha-mcp
    ];
}
