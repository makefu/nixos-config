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
  krebs.Reaktor.enable = true;
  krebs.Reaktor.debug = true;
  # krebs.Reaktor.nickname = "test-reaktor";
  # TODO: make origin variable
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
