{ config, lib, pkgs, ... }:

{
  virtualisation.virtualbox.host.enable = true;
  nixpkgs.config.virtualbox.enableExtensionPack = true;
  virtualisation.virtualbox.host.enableHardening = false;

  users.extraGroups.vboxusers.members = [ config.krebs.build.user.name ];
}
