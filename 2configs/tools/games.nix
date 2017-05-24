{ pkgs, ... }:

{
  krebs.per-user.makefu.packages = with pkgs; [
    steam
    games-user-env
  ];
}
