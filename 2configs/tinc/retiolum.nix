{ pkgs, lib, config, ... }:
{
  imports = [
    ../binary-cache/lass.nix
  ];

  krebs.tinc.retiolum = {
    enable = true;
    extraConfig = ''
      StrictSubnets = yes
      ${lib.optionalString (config.krebs.build.host.nets.retiolum.via != null) ''
        LocalDiscovery = no
      ''}
    '';
    privkey = config.sops.secrets."${config.clan.core.machineName}-retiolum.rsa_key.priv".path;
    privkey_ed25519 = config.sops.secrets."${config.clan.core.machineName}-retiolum.ed25519_key.priv".path;
  };
  environment.systemPackages = [ pkgs.tinc ];
  networking.firewall.allowedTCPPorts = [ config.krebs.build.host.nets.retiolum.tinc.port ];
  networking.firewall.allowedUDPPorts = [ config.krebs.build.host.nets.retiolum.tinc.port ];

}
