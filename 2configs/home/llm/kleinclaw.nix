{ config, self, ... }:
let
  hermes = config.services.hermes-agent;
  kleinclaw-src = self.inputs.kleinclaw;
in
{
  # Kleinclaw is an OpenClaw plugin that opencrow could not load, so we skip
  # the plugin layer and drive the embedded miniclaw CLI from the shell
  # (on the container PATH via agent.nix), guided by this helper skill.
  # Mounted at /skills/kleinanzeigen-helper by the skills.external_dirs root.
  services.hermes-agent.container.extraVolumes = [
    "${kleinclaw-src}/skills/kleinanzeigen-helper-skill:/skills/kleinanzeigen-helper:ro"
  ];
}
