{ config, ... }: {

  sops.secrets."ssh_host_rsa_key" = {};
  sops.secrets."ssh_host_ed25519_key" = {};
  services.openssh.hostKeys = [
    { bits = 4096; path = config.sops.secrets."ssh_host_rsa_key".path; type = "rsa"; }
    { path = config.sops.secrets."ssh_host_ed25519_key".path; type = "ed25519"; } ];
}
