{ config, ... }:
{
  sops.defaultSopsFile = ../../secrets/common.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  sops.secrets = {
    "passwd/makefu".neededForUsers = true;
    "passwd/root".neededForUsers = true;
  };
  users.users = {
    makefu.passwordFile = config.sops.secrets."passwd/makefu".path;
    root.passwordFile = config.sops.secrets."passwd/root".path;
  };
}
