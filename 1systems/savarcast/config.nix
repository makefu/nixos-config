{ config, lib, pkgs, ... }:

{
  imports = [
      # ../../2configs/temp/testusers.nix

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
      ../../2configs/bgt/login.nix

      # Tools
      ../../2configs/tools/core.nix
      ../../2configs/zsh-user.nix
      ../../2configs/mosh.nix
      # Networking
      ../../2configs/tinc/retiolum.nix
      ../../2configs/wireguard/wiregrill.nix

      # services
      ../../2configs/bgt/savarcast/download.nix
      ../../2configs/bgt/savarcast/comments.nix

      # backup
      #../../2configs/backup/state.nix
      # TODO: migration required
      # ../../2configs/bgt/backup.nix
      # TODO: isso + isso backup

      # misc
      ../../2configs/support-nixos.nix
      ../../2configs/headless.nix
    ];
    # TODO: ingo:
    # "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEA5G4SzPWZAJHrxpN2hQ0TzfPz5KO4eZISZxL3j/pkPs+6/YLXwB22AuU5qvNBi5uVIIZNqJBoaAcj/NePkiu6i2iAVzntAVWhBQlCLIlN0YXwXZ7E19fVUxvG65XV8D86YXSKrKkeDqk6SmQhReeWexMxTIKtj9Ipa7i9lPHBsls="

  krebs.build.host = config.krebs.hosts.savarcast;

  # Network
  networking = {
    useDHCP = lib.mkDefault true;
    firewall = {
        allowedTCPPorts = [ 80 443 ];
        allowPing = true;
        logRefusedConnections = false;
    };
    nameservers = [ "8.8.8.8" ];
  };
}
