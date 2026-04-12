{ pkgs, inputs, ... }:
let
  aiTools = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  micsSkillsPkgs = inputs.mics-skills.packages.${pkgs.stdenv.hostPlatform.system};
in
{

    imports = [
      inputs.mics-skills.homeManagerModules.default
    ];
    home.file.".claude/CLAUDE.md".source = ./.claude/CLAUDE.md;
    home.file.".claude/settings.json".source = ./.claude/settings.json;
    home.file.".claude/skills/coordinator".source =
      "${aiTools.workmux}/share/workmux/skills/coordinator";

    home.file.".config/workmux/config.yaml".source = ./.config/workmux/config.yaml;
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

    ];
}
