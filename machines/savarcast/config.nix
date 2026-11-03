{ config, lib, pkgs, ... }:

{
  imports = [
      # ../../2configs/temp/testusers.nix

      # hardware
      ./proxmox-vm

      ../../2configs


      # Monitoring
      ../../2configs/bgt/telegraf.nix
      # ../../2configs/nix-community/supervision.nix

      # users
      ../../2configs/home-manager
      ../../2configs/home-manager/cli.nix


      # Security
      # ../../2configs/sshd-totp.nix
      ../../2configs/bgt/login.nix
      {
        services.openssh.settings.PermitRootLogin = "prohibit-password"; # make default explicit, root user may never log in via password on savarcast
      }

      # Tools
      ../../2configs/tools/core.nix
      ../../2configs/zsh
      # ../../2configs/mosh.nix
      # Networking
      # savarcast is special-purpose system, no need for other ways inside the machine, ingo will fix if we shout
      # ../../2configs/tinc/retiolum.nix
      # ../../2configs/wireguard/wiregrill-client.nix

      # services
      ../../2configs/bgt/savarcast/download.nix
      ../../2configs/bgt/savarcast/comments.nix
      ../../2configs/bgt/savarcast/search.nix
      ../../2configs/bgt/gecloudpad/default.nix
      ../../2configs/bgt/etherpad.binaergewitter.de.nix
      ../../2configs/bgt/plan.binaergewitter.de.nix

      # TODO: migration required
      # ../../2configs/bgt/backup.nix
      # TODO: isso + isso backup

    ];

  clan.core.networking.targetHost = "root@savarcast";
  # Network
  networking = {
    useDHCP = true;
    firewall = {
        allowedTCPPorts = [ 80 443 ];
        allowPing = true;
        logRefusedConnections = false;
    };
    nameservers = [ "8.8.8.8" ];
  };
}
