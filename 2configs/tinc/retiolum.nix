{ pkgs, lib, config, ... }:
{
  imports = [
    ../binary-cache/lass.nix
  ];
  krebs.tinc.retiolum.enable = true;
  krebs.tinc.retiolum.extraConfig = ''
      StrictSubnets = yes
      ${lib.optionalString (config.krebs.build.host.nets.retiolum.via != null) ''
        LocalDiscovery = no
      ''}
    '';
  #krebs.tinc.retiolum.connectTo = [ "gum" ];
  environment.systemPackages = [ pkgs.tinc ];
  networking.firewall.allowedTCPPorts = [ config.krebs.build.host.nets.retiolum.tinc.port ];
  networking.firewall.allowedUDPPorts = [ config.krebs.build.host.nets.retiolum.tinc.port ];

}
