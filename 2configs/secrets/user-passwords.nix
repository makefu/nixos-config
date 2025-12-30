{ config, lib, ... }:
{
  imports = [ ./default.nix ];

  sops.secrets = {
    "passwd-makefu".neededForUsers = true;
    "passwd-root".neededForUsers = true;
  };

  users.users = {
    makefu.hashedPasswordFile = lib.mkDefault config.sops.secrets."passwd-makefu".path;
    root.hashedPasswordFile = lib.mkDefault config.sops.secrets."passwd-root".path;
  };
}
