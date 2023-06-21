{ config, ... }:
{
  imports = [ ./default.nix ];

  sops.secrets = {
    "passwd/makefu" = {
      neededForUsers = true;
      sopsFile = ../../secrets/common.yaml;
    };
    "passwd/root" = {
      neededForUsers = true;
      sopsFile = ../../secrets/common.yaml;
    };
  };

  users.users = {
    makefu.passwordFile = config.sops.secrets."passwd/makefu".path;
    root.passwordFile = config.sops.secrets."passwd/root".path;
  };
}
