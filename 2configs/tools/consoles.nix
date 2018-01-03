{ pkgs, ... }:
{
  users.users.makefu.packages = with pkgs; [
    opl-utils
    hdl-dump
    bin2iso
  ];
}
