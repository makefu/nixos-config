{ pkgs, config, ... }:
{
  virtualisation.docker = {
    enable = true;
    storageDriver = "devicemapper";
  };
  environment.systemPackages = with pkgs;[
    docker
    docker-compose
  ];
  users.users.${config.krebs.build.user.name}.extraGroups = [ "docker" ];
}
