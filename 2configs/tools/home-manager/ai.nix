{ pkgs, inputs, ... }:
let
  aiTools = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  micsSkillsPkgs = inputs.mics-skills.packages.${pkgs.stdenv.hostPlatform.system};
  caveman = inputs.caveman;
  # caveman ships its opencode plugin under src/plugins/opencode and the
  # plugin's require() bridge expects caveman-config to live next to plugin.js
  # as a .cjs sibling (the plugin dir is "type": "module").
  cavemanOpencode = "${caveman}/src/plugins/opencode";
in
{

    imports = [
      inputs.mics-skills.homeModules.default
    ];
    services.pueue.enable = true;
    home.file.".claude/CLAUDE.md".source = ./.claude/CLAUDE.md;
    home.file.".claude/settings.json".source = ./.claude/settings.json;
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
      skillsSrc = inputs.mics-skills;
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
