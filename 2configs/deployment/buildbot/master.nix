{inputs,config, ...}:
let
  domain = "build.euer.krebsco.de";
in {

  imports = [
    inputs.buildbot-nix.nixosModules.buildbot-master
  ];

  services.nginx.virtualHosts."${domain}" = {
    enableACME = true;
    forceSSL = true;
  };

  sops.secrets.buildbot-github-oauth-secret = { };
  sops.secrets.buildbot-github-token = { };
  sops.secrets.buildbot-github-webhook-secret = { };
  sops.secrets.buildbot-nix-workers = { };

  services.buildbot-nix.master = {
    enable = true;
    admins = [ "makefu" ];
    buildSystems = [ "x86_64-linux" "aarch64-linux" ];
    inherit domain;
    evalMaxMemorySize = "4096";
    evalWorkerCount = 16;
    workersFile = config.sops.secrets.buildbot-nix-workers.path;
    github = {
      tokenFile = config.sops.secrets.buildbot-github-token.path;
      webhookSecretFile = config.sops.secrets.buildbot-github-webhook-secret.path;
      oauthSecretFile = config.sops.secrets.buildbot-github-oauth-secret.path;
      oauthId = "Ov23lizFP7t7qoE9FuDA";
      user = "krebs-bob";
      topic = "buildbot";
    };
  };
}
