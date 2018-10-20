
{
  systemd.services.gitlab-runner.path = [
    "/run/wrappers" # /run/wrappers/bin/su
    "/" # /bin/sh
  ];
  services.gitlab-runner = {
    enable = true;
    configOptions =
    { concurrent = 1;
      runners = [
        { builds_dir = "";
          #docker =
          #{ cache_dir = "";
          #  disable_cache = true;
          #  host = ""; image = "nixos/nix:2.1.3";
          #  privileged = true;
          #};
          #executor = "docker";
          # name = "docker-nix";
          name = "gum-shell";
          executor = "shell";
          environment = [ "PATH=/bin:/run/wrappers/bin:/etc/per-user/gitlab-runner/bin:/etc/per-user-pkgs/gitlab-runner/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin" ];
          # generate via `gitlab-runner register`
          token = import <secrets/shackspace-gitlab-ci-token.nix>;
          url = "https://git.shackspace.de/";
        }
      ];
    };
  };
}
