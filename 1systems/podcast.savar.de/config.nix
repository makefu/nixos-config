{ config, lib, pkgs, ... }:

{
  imports = [

      # hardware
      ./proxmox-vm

      ../../2configs


      # Monitoring
      ../../2configs/nix-community/supervision.nix

      # users
      ../../2configs/home-manager
      ../../2configs/home-manager/cli.nix


      # Security
      ../../2configs/sshd-totp.nix

      # Tools
      ../../2configs/tools/core.nix
      ../../2configs/zsh-user.nix
      ../../2configs/mosh.nix
      # Networking
      ../../2configs/tinc/retiolum.nix
      ../../2configs/wireguard/wiregrill.nix

      # services
      ../../2configs/bgt/download.binaergewitter.de.nix

      # backup
      ../../2configs/backup/state.nix
      # TODO: migration required
      # ../../2configs/bgt/backup.nix

      # misc
      ../../2configs/support-nixos.nix
      ../../2configs/headless.nix
    ];

  sops.secrets."ssh_host_rsa_key" = {};
  sops.secrets."ssh_host_ed25519_key" = {};
  services.openssh.hostKeys = lib.mkForce [
    { bits = 4096; path = (config.sops.secrets."ssh_host_rsa_key".path); type = "rsa"; }
    { path = config.sops.secrets."ssh_host_ed25519_key".path; type = "ed25519"; } ];

  krebs.build.host = config.krebs.hosts.podcast.savar.de;

  # Network
  networking = {
    firewall = {
        allowedTCPPorts = [ 80 443 ];
        allowPing = true;
        logRefusedConnections = false;
    };
    nameservers = [ "8.8.8.8" ];
  };
}
