{ config, ... }:
{
  imports = [ ./default.nix ];

  sops.secrets = {
    "passwd-makefu".neededForUsers = true;
    "passwd-root".neededForUsers = true;
  };

  users.users = {
    makefu.hashedPasswordFile = config.sops.secrets."passwd-makefu".path;
    root.hashedPasswordFile = config.sops.secrets."passwd-root".path;
  };
}
