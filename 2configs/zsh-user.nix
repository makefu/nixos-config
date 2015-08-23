{ config, lib, pkgs, ... }:
##
with lib;
let
  mainUser = config.krebs.build.user.name;
in
{
  programs.zsh.enable = true;
  users.extraUsers.${mainUser}.shell = "/run/current-system/sw/bin/zsh";
}
