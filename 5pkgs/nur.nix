{ pkgs ? import <nixpkgs> {} }:

{
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ../3modules/default.nix;
  overlays.full = import ./default.nix;
  pkgs = import ./default.nix pkgs pkgs;
} // (import ./default.nix pkgs pkgs)

