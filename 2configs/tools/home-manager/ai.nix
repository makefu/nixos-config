{ pkgs, inputs }:
let
  aiTools = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  micsSkillsPkgs = inputs.mics-skills.packages.${pkgs.stdenv.hostPlatform.system};
in
{

    imports = [
      inputs.mics-skills.homeManagerModules.default
    ];
    programs.mic-skills = {
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
    home.file.".claude/skills/coordinator".source =
      "${aiTools.workmux}/share/workmux/skills/coordinator";
    packages = with aiTools;[
      workmux
      claude-code
      pi
      pkgs.pueue
    ];
}
