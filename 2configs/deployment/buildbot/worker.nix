{...}@inputs:
{
  imports = [
    inputs.buildbot-nix.nixosModules.buildbot-worker
  ];
  sops.secrets.buildbot-github-nix-worker-password = { };

  services.buildbot-nix.worker = {
    enable = true;
    workerPasswordFile = config.sops.secrets.buildbot-github-nix-worker-password.path;
  };
}
