{ config, ... }:
{
  state = [ "/var/lib/netbird-wt0" ];
  sops.secrets.netbird-homelab-setupkey.neededForUsers = true;
  services.resolved.enable = true;
  services.netbird.clients.wt0 = {

    # Automatically login to your Netbird network with a setup key
    # This is mostly useful for server computers.
    # For manual setup instructions, see the wiki page section below.

    login = {
      enable = true;
      setupKeyFile = config.sops.secrets.netbird-homelab-setupkey.path;
      systemdDependencies = [ ];
    };

    # Port used to listen to wireguard connections
    port = 51821;

    #ui.enable = true;
    #ui.enable = false;

    # This opens ports required for direct connection without a relay
    openFirewall = true;

    # This opens necessary firewall ports in the Netbird client's network interface
    openInternalFirewall = true;
  };
}
