{ config, lib, pkgs, ... }:

with pkgs;
let
  nixos-version-script = pkgs.writeScript "nix-version" ''
  #! /bin/sh
  . /etc/os-release
  echo "$PRETTY_NAME"
  '';
in {
  krebs.Reaktor.enable = true;
  krebs.Reaktor.nickname = "test-reaktor";
  krebs.Reaktor.extraConfig = ''
  public_commands.insert(0,{
    'capname' : "nixos-version",
    'pattern' : indirect_pattern.format("nixos-version"),
    'argv'    : ["${nixos-version-script}"],
    'env'     : { 'state_dir': workdir } })
  '';
}

