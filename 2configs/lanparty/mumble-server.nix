{ config, ... }:
{
  networking.firewall.allowedTCPPorts = [ 64738 ];
  networking.firewall.allowedUDPPorts = [ 64738 ];
  services.murmur = {
    enable = true;
    welcometext = "Welcome to the LANest Party mumble server";
    bonjour = true;
    hostName = "0.0.0.0";
    sendVersion = true;
  };
}
