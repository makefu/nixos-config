{ pkgs, ... }:
{
  users.users.makefu.packages = with pkgs; [
    opl-utils
    hdl-dump
    bin2iso
    cue2pops
    nx_game_info
    hactool
    nsrenamer
  ];
}
