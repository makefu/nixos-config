{ config, ... }:
let
  hostKey = "/etc/secrets/initrd/ssh_host_ed25519_key";
in
{
  state = [ hostKey ];
  boot.initrd = {
    systemd = {
      enable = true;
      # Specify which programs need to be available during early boot
      # Configure networking using systemd's network manager
      network = {
        networks = {
          "enp2s0" = { 
            matchConfig = {
              Name = "enp2s0";  # Matches the network interface by name
            };
            networkConfig = {
              DHCP = "yes";  # Enable DHCP to automatically get an IP address
            };
          };
        };
      };
    };
      network = {
      enable = true;
      ssh = {
        enable = true;
        port = 22;
        # Only allow running the unlock service when connecting via SSH
        authorizedKeys = [
          config.krebs.users.makefu.pubkey
        ];
        # Location of the SSH host key
        hostKeys = [ 
          hostKey
        ];
      };
    };
  };
}
