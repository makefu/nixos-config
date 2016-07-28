{lib, config, ... }:
{
  # TODO do not know why we need to force it, port is only set via default to 655
  krebs.build.host.nets.siem.tinc.port = lib.mkForce 1655;

  networking.firewall.allowedUDPPorts = [ 1665 ];
  networking.firewall.allowedTCPPorts = [ 1655 ];
  krebs.tinc.siem = {
    enable = true;
    connectTo = [ "shoney" ];
  };
}
