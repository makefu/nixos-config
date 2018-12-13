{ pkgs, config, ... }:
{
  imports = [
    ../binary-cache/lass.nix
  ];
  krebs.tinc.retiolum.enable = true;
  environment.systemPackages = [ pkgs.tinc ];
  networking.firewall.allowedTCPPorts = [ config.krebs.build.host.nets.retiolum.tinc.port ];
  networking.firewall.allowedUDPPorts = [ config.krebs.build.host.nets.retiolum.tinc.port ];
}
