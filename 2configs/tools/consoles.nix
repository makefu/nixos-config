{ pkgs, ... }:
{
  users.users.makefu.packages = with pkgs; [
    # PS2
    opl-utils
    #opl-pc-tools
    hdl-dump
    bin2iso
    cue2pops

    # PS4
    pkgrename

    # switch
    nx_game_info
    hactool
    nsrenamer
    ns-usbloader
    sfo
    exfatprogs exfat-utils exfat
  ];
}
