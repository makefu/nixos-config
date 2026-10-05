{ pkgs, ... }:

{
  imports = [
    # ./steam.nix
  ];
  users.users.makefu.packages = with pkgs; [
    # kaputt:
    # games-user-env
    # pkg2zip
    wine
    steam
    steam-run
  ];
}
