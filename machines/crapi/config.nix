{ config, pkgs, lib, ... }:
{
  imports = [
    <stockholm/makefu>
    ./hardware-config.nix
    <stockholm/makefu/2configs>
    <stockholm/makefu/2configs/tinc/retiolum.nix>
    <stockholm/makefu/2configs/save-diskspace.nix>

  ];
  krebs.build.host = config.krebs.hosts.crapi;

  services.openssh.enable = true;

}
