{ pkgs, ... }:

{
  imports = [
    # ./steam.nix
  ];
  users.users.makefu.packages = with pkgs; [
    games-user-env
    wine
    pkg2zip
    steam
    steam-run
  ];
}
