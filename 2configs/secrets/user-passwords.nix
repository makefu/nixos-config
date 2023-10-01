{ config, ... }:
{
  imports = [ ./default.nix ];

  sops.secrets = {
    "passwd-makefu".neededForUsers = true;
    "passwd-root".neededForUsers = true;
  };

  users.users = {
    makefu.passwordFile = config.sops.secrets."passwd-makefu".path;
    root.passwordFile = config.sops.secrets."passwd-root".path;
  };
}
