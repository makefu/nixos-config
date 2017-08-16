{ pkgs, ... }:
{
  virtualisation.docker.enable = true;
  environment.systemPackages = with pkgs;[
    docker
    docker_compose
  ];
}
