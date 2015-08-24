{ config, lib, pkgs, ... }:

let
  mainUser = config.krebs.build.user;
in {
  virtualisation.libvirtd.enable = true;
  users.extraUsers.${mainUser.name}.extraGroups = [ "libvirtd" ];
}
