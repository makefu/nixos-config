{ config, ... }:
{
  # sops.defaultSopsFile = ../.. + "/secrets/${config.clan.core.settings.machine.name}.yaml";
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
}
