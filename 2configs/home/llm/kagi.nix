{ config, self, pkgs, ... }:
let
  hermes = config.services.hermes-agent;
  tokenFile = "/run/secrets/kagi-session-token";
in
{
  # Kagi session token, managed as a clan/sops secret.
  # Set with: clan secrets set --machine omo opencrow-kagi-session-token
  # group/mode: the hermes container bind-mounts this file into
  # /run/secrets/kagi-session-token; the in-container agent runs as the same
  # numeric uid/gid as the host hermes user, so group-read is sufficient.
  sops.secrets.opencrow-kagi-session-token = {
    group = hermes.group;
    mode = "0440";
  };

  # Skill dir mounted under the /skills external_dirs root (agent.nix).
  # The SKILL.md lives in the package's `skill/` subdir of the repo.
  services.hermes-agent.container.extraVolumes = [
    "${self.inputs.mics-skills}/kagi-search/skill:/skills/kagi-search:ro"
  ];


  # kagi-search reads the token via password_command. cat the bind-mounted
  # secret directly. The raw token is used verbatim (no "token=" prefix), so
  # the script takes the whole output as the token.
  #
  # HOME inside the container is /home/hermes, which is the host
  # ${stateDir}/home bind mount — so the config lands where both the gateway
  # process and its terminal-tool subprocesses resolve it.
  systemd.tmpfiles.rules = [
    # .config itself must be hermes-owned, otherwise systemd-tmpfiles aborts
    # with "unsafe path transition" when descending from the hermes-owned
    # state dir into a root-owned .config and never creates config.json.
    "d ${hermes.stateDir}/home/.config 0750 ${hermes.user} ${hermes.group} -"
    "d ${hermes.stateDir}/home/.config/kagi 0750 ${hermes.user} ${hermes.group} -"
    ''f ${hermes.stateDir}/home/.config/kagi/config.json 0640 ${hermes.user} ${hermes.group} - {"password_command":"cat ${tokenFile}","timeout":30,"max_retries":5}''
  ];
}
