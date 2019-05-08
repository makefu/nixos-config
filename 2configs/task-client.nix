{ pkgs, ... }:
{
  users.users.makefu.packages = [
    pkgs.taskwarrior
  ];

}
