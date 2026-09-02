{ ... }:
{
  home-manager.users.makefu.imports = [ ./home-manager/ai.nix ];
  state = [ "/home/makefu/.claude.json" ];

  # Bearer token for the p0 vLLM endpoint that pi and opencode default to.
  # Host-prefixed because only x has the age key for it; a second host
  # importing this needs its own `clan secrets machines add-secret`.
  sops.secrets.x-p0-inference-api-key = {
    owner = "makefu";
    mode = "0400";
  };
}
