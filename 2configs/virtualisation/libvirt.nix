{ config, lib, pkgs, ... }:

let
  mainUser = config.krebs.users.makefu;
in {
  virtualisation.libvirtd.enable = true;
  users.extraUsers.${mainUser.name}.extraGroups = [ "libvirtd" ];
  networking.firewall.checkReversePath = false; # TODO: unsolved issue in nixpkgs:#9067 [bug]
}
