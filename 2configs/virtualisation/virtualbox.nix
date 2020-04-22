{ config, lib, pkgs, ... }:

{
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
  # virtualisation.virtualbox.host.enableHardening = false;
  users.extraGroups.vboxusers.members = [ config.krebs.build.user.name ];
}
