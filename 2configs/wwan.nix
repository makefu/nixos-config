{ config, lib, pkgs, ... }:
let
  mainUser = config.krebs.build.user;
in {
  environment.systemPackages = with pkgs;[
    wvdial
  ];

  users.extraUsers.${mainUser.name}.extraGroups = [ "dialout" ];
}
