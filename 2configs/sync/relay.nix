{config, ... }:
{
  services.syncthing = {
    relay = {
      enable = true;
      providedBy = "makefu";
    };
  };
  networking.firewall.allowedTCPPorts = [
    config.services.syncthing.relay.port
    config.services.syncthing.relay.statusPort
  ];
}
