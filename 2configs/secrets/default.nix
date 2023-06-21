{ config, ... }:
{
  sops.defaultSopsFile = ../.. + "/secrets/${config.krebs.build.host.name}.yaml";
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
}
