{ pkgs, ... }:

{
  imports = [
    # ./steam.nix
  ];
  users.users.makefu.packages = with pkgs; [
    # kaputt:
    # games-user-env
    wine
    pkg2zip
    steam
    steam-run
  ];
}
