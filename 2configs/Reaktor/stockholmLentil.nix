{ config, lib, pkgs, ... }:

with pkgs;
let
  random-issue = pkgs.writeScript "random-issue" (builtins.readFile ./random-issue.sh);
  random-issue-path = lib.makeSearchPath "bin" (with pkgs; [
                        coreutils
                        git
                        gnused
                        lentil]);
in {
  # TODO: make origin a variable, <- module is generic enough to handle different origins, not only stockholm
  krebs.Reaktor.extraConfig = ''
  public_commands.insert(0,{
    'capname' : "stockholm-issue",
    'pattern' : indirect_pattern.format("stockholm-issue"),
    'argv'    : ["${random-issue}"],
    'env'     : { 'state_dir': workdir,
                  'PATH':'${random-issue-path}',
                  'origin':'http://cgit.pnp/stockholm' } })
  '';
}
