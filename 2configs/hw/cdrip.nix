{ pkgs, ... }:
{
  users.users.makefu = {
    extraGroups = [ "cdrom" ];
    packages = [ pkgs.glyr pkgs.abcde ];
  };
}
