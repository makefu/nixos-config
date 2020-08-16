{ pkgs,... }:
# TODO: dependencies: coreutils, nx_game_info,
pkgs.writeScriptBin "nsrenamer" ./nsrenamer.sh
