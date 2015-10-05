{ config, lib, pkgs, ... }:

with pkgs;
let
  rpkg = pkgs.substituteAll( {
    name="random-emoji";
    dir= "bin";
    isExecutable=true;
    src= ./random-emoji.sh;
    });
  rpkg-path = lib.makeSearchPath "bin" (with pkgs; [
                        coreutils
                        gnused
                        gnugrep
                        curl]);
in {
  # TODO: make origin a variable, <- module is generic enough to handle different origins, not only stockholm
  krebs.Reaktor.extraConfig = ''
  public_commands.insert(0,{
    'capname' : "emoji",
    'pattern' : indirect_pattern.format("emoji"),
    'argv'    : ["${rpkg}/bin/random-emoji"],
    'env'     : { 'PATH':'${rpkg-path}' } })
  '';
}
