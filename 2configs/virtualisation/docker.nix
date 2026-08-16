{ pkgs, config, ... }:
{
  virtualisation.docker = {
    enable = true;
    # storageDriver = "devicemapper";
    storageDriver = "overlay2";
  };
  environment.systemPackages = with pkgs;[
    docker
    docker-compose
  ];
  users.users.makefu.extraGroups = [ "docker" ];
}
