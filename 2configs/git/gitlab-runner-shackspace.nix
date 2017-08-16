{ config, ... }:
let
  url = "https://git.shackspace.de/";
  # generate token from CI-token via:
  ## gitlab-runner register
  token = import <secrets/shackspace-gitlab-ci-token.nix> ;
in {
  virtualisation.docker.enable = true;
  services.gitlab-runner = {
    enable = true;
    gracefulTimeout = "120min";
    # configFile = "/var/src/secrets/runner.toml";
    configOptions = {
      concurrent = 2;
      runners = [{
        name = "nix-krebs-1.11";
        inherit token url;
        executor = "docker";
        builds_dir = "";
        docker = {
          host = "";
          image = "nixos/nix:1.11";
          privileged = false;
          disable_cache = false;
          volumes = ["/cache"];
          shm_size = 0;
        };
        cache = {};
      }];
    };
  };
}
